require 'ostruct'

class Mapping
  include Mongoid::Document
  include Mongoid::History::Trackable
  include Taggable

  paginates_per 50

  track_history :on => [:title, :old_url, :new_url, :status, :notes, :tags_list_cache]

  scope :by_old_url, proc {|string| where({ :old_url => Regexp.new(Regexp.escape(string),"i") }) }
  scope :by_new_url, proc {|string| where({ :new_url => Regexp.new(Regexp.escape(string),"i") }) }

  field :title,             type: String
  field :old_url,           type: String
  field :new_url,           type: String
  field :status,            type: Integer, default: 301
  field :alternative_urls,  type: String
  field :notes,             type: String, default: nil

  validates :old_url, :format => { :with => /\A#{URI::regexp}\z/ }, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :new_url, :format => { :with => /\A#{URI::regexp}\z/ }, :if => proc{|atts| atts.status == 301 and ! atts.new_url.blank? }
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
    match_count = context.tagged_with_all([filter_tag]).count
    percentage = context.count > 0 ? (match_count.to_f / context.count * 100).round(1) : 0

    OpenStruct.new(:count => match_count, :total => context.count, :percentage => percentage, :tag => filter_tag)
  end

  def status=(code)
    self[:status] = code

    new_tag = case code.to_i
              when 301 then "content"
              when 410 then "gone"
              else nil
              end
    self.update_tag_for("destination", new_tag ) unless self.tag_for("destination") == "gone-welsh"
  end

  def is_redirect?
    status == 301
  end

  class MappingNotFound < Exception; end
  class URLNotProvided < Exception; end

  private
    def parameterize_tags
      self.tags = tags_list.split(",").map{|tag| tag.strip.downcase.gsub(" ","-") }
    end

end
