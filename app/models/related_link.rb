class RelatedLink
  include Mongoid::Document

  field :url, type: String
  field :title, type: String

  validates :url, :title, :presence => true
end