collection @mappings, :root => "mappings", :object_root => false

attributes :id, :title, :old_url, :status, :new_url
node :tags do |m|
  m.tags.map(&:whole_tag)
end
attribute :notes
attribute :search_query

child :related_links => :related_links do
  attributes :title, :url
end
