object @mapping

attributes :id, :title, :old_url, :status, :new_url

node :tags do |m|
  m.tags.map(&:whole_tag)
end

attribute :notes
