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

  def self.progress(tags_array)
    status_tags = Tag.find_by_group(Tag::STATUS_GROUP).map(&:whole_tag)

    total_count = self.tagged_with_all(tags_array).tagged_with_any(status_tags).count
    done_count = self.tagged_with_all(tags_array + [Tag::STATUS_DONE_TAG]).count

    OpenStruct.new(:count => total_count, :done => (done_count.to_f / total_count.to_f * 100).round(1))
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