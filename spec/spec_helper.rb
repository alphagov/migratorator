ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'database_cleaner'

def login_as_stub_user
  @user = User.create!(:name => 'Stub User')
  request.env['warden'] = stub(:authenticate! => true, :authenticated? => true, :user => @user)
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:each) do
    DatabaseCleaner.orm = "mongoid"
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
