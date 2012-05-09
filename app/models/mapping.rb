require 'ostruct'

class Mapping
  include Mongoid::Document
  include Taggable

  field :title,         type: String
  field :old_url,       type: String
  field :new_url,       type: String
  field :status,        type: Integer, default: 301
  field :notes,         type: String, default: nil
  field :search_query,  type: String, default: nil

  validates :old_url, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :new_url, :presence => true, :if => :is_redirect?
  validates :status, :inclusion => { :in => [301, 410], :allow_blank => true }

  embeds_many :related_links
  accepts_nested_attributes_for :related_links, :reject_if => proc {|atts| atts['url'].blank? }, :allow_destroy => true

  def self.find_by_old_url(param)
    raise URLNotProvided.new if !param or param.empty?
    self.where( old_url: URI::decode(param) ).first || raise(MappingNotFound.new)
  end

  def self.progress(tags_array, filter_tag)
    context = tags_array.any? ? Mapping.tagged_with_all(tags_array) : Mapping

    match_count = context.tagged_with_all(tags_array + [filter_tag]).count
    percentage = context.count > 0 ? (match_count.to_f / context.count * 100).round(1) : 0

    OpenStruct.new(:count => match_count, :total => context.count, :percentage => percentage, :tag => filter_tag)
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