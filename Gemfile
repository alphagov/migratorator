source 'http://rubygems.org'

gem 'rails', '3.1.3'
gem "mongoid", "~> 2.3"
gem "bson_ext", "~> 1.5"

gem 'rabl'
gem 'nested_form', :git => "git://github.com/ryanb/nested_form.git"

group :passenger_compatibility do
  gem 'rack', '1.3.5'
  gem 'rake', '0.9.2'
end

group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.6'
  gem 'capybara'
  gem 'capybara-webkit'
end

gem 'unicorn'

gem 'jquery-rails'
