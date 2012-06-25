require 'ostruct'

class Mapping
  include Mongoid::Document
  include Mongoid::History::Trackable
  include Taggable

  paginates_per 50

  track_history :on => [:title, :old_url, :new_url, :status, :notes, :tags_list_cache]

  scope :by_old_url, proc {|string| where({ :old_url => Regexp.new(Regexp.escape(string),"i") }) }
  scope :by_new_url, proc {|string| where({ :new_url => Regexp.new(Regexp.escape(string),"i") }) }

  field :title,         type: String
  field :old_url,       type: String
  field :new_url,       type: String
  field :status,        type: Integer, default: 301
  field :notes,         type: String, default: nil

  validates :old_url, :presence => true, :uniqueness => { :case_sensitive => false }
  validate :new_url_is_on_govuk, :if => :is_redirect?
  validates :new_url, :format => { :with => URI::regexp }, :if => proc{|atts| atts.status == 301 and ! atts.new_url.blank? }
  validates :status, :inclusion => { :in => [301, 410], :allow_blank => true }

  default_scope order_by([:title, :asc])

  additional_tag "reviewed", "yes", "no"

  def self.find_by_old_url(param)
    raise URLNotProvided.new if !param or param.empty?
    self.where( old_url: URI::decode(param) ).first || raise(MappingNotFound.new)
  end

  def self.find_by_id(param)
    raise URLNotProvided.new if !param or param.empty?
    self.find(param)
  rescue Mongoid::Errors::DocumentNotFound, BSON::InvalidObjectId
    raise MappingNotFound.new
  end

  def self.progress(context, filter_tag)
    # context = tags_array.any? ? Mapping.tagged_with_all(tags_array) : Mapping

    match_count = context.tagged_with_all([filter_tag]).count
    percentage = context.count > 0 ? (match_count.to_f / context.count * 100).round(1) : 0

    OpenStruct.new(:count => match_count, :total => context.count, :percentage => percentage, :tag => filter_tag)
  end

  def is_redirect?
    status == 301
  end

  class MappingNotFound < Exception; end
  class URLNotProvided < Exception; end

  private
    def new_url_is_on_govuk
      return if self.new_url.blank?
      self.errors.add(:new_url, 'is not a GOV.UK url') unless self.new_url.match(/^https?:\/\/(www\.)?gov\.uk/)
    end

    def parameterize_tags
      self.tags = tags_list.split(",").map{|tag| tag.strip.downcase.gsub(" ","-") }
    end

end