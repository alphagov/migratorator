class Mapping
  include Mongoid::Document
  include Mongoid::Taggable

  field :title,         type: String
  field :old_url,       type: String
  field :new_url,       type: String
  field :status,        type: Integer, default: 301
  field :notes,         type: String, default: nil
  field :search_query,  type: String, default: nil

  validates :old_url, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :new_url, :presence => true, :if => :is_redirect?
  validates :status, :inclusion => { :in => [301, 410], :allow_blank => true }

  before_validation :parameterize_tags

  embeds_many :related_links
  accepts_nested_attributes_for :related_links

  # fix tags to accept our json key as an array
  alias_method :tags_list=, :tags=
  alias_method :tags=, :tags_array=

  # return a list of all the tags we know about and group them by their tag type
  # (aka the bit before the first colon)
  def self.tags
    super.group_by {|tag| tag.split(":").size > 1 ? tag.split(":").first : "Other" }
  end

  # return all the tags for a mapping as an array of hashes, and split away the tag type
  def tags
    tags_array.map { |a|
      { :type => a.split(":")[0], :name => (a.split(":")[1] || "").strip }
    }
  end

  def tags_list
    tags_array.join(", ")
  end

  def self.find_by_old_url(param)
    raise URLNotProvided.new if !param or param.empty?
    self.where( old_url: param ).first || raise(MappingNotFound.new)
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