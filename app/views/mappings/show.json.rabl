object @mapping

attributes :id, :title, :old_url, :status, :new_url
attribute :tags_array => :tags
attribute :notes
attribute :search_query
child :related_links => :related_links do
  attributes :title, :url
end