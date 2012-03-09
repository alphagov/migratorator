class Mapping
  include Mongoid::Document
  include Mongoid::Taggable

  field :title,         type: String
  field :old_url,       type: String
  field :new_url,       type: String
  field :status,        type: Integer, default: 302
  field :notes,         type: String, default: nil
  field :search_query,  type: String, default: nil

  embeds_many :related_links
  accepts_nested_attributes_for :related_links

  def self.find_by_old_url(param)
    raise URLNotProvided.new if !param or param.empty?
    self.where( old_url: param ).first || raise(MappingNotFound.new)
  end

  class MappingNotFound < Exception; end
  class URLNotProvided < Exception; end

end