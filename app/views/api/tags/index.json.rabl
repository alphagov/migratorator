object false

child @tags do
  attribute :group, :name, :whole_tag
end

node(:pages) do
  {
    :current_page => @tags.current_page,
    :total_pages => @tags.num_pages,
    :per_page => @tags.limit_value,
    :total_entries => @tags.count
  }
end