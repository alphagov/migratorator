FactoryGirl.define do

  factory :mapping do
    sequence(:title) {|n| "Test #{n}" }
    sequence(:old_url) {|n| "http://old.com/foo-#{n}" }
    sequence(:new_url) {|n| "http://www.gov.uk/new-url-#{n}" }
    status 301
    notes "Example notes"
    tags ["section:test","status:done","apple"]
  end

  factory :tag do
    sequence(:whole_tag) {|n| "foo:bar-#{n}" }
  end

  factory :user do
    sequence(:name) { |n| "Alice #{n}"}
    permissions { ["signin"] }
  end
end