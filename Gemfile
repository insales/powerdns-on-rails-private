source 'https://rubygems.org'

gem 'rails', '6.0.3.7'
# gem 'rails', '6.1.3.2'

gem 'unicorn'

# gem 'sass-rails'
# gem 'uglifier'

gem 'pg', '~> 1.1.4'
gem 'haml'
gem 'jquery-rails'
gem 'will_paginate', '~> 3.3'
gem "audited", '~>4.0'
gem 'inherited_resources'
gem 'devise', '~>4.0'
gem "devise-encryptable"
gem 'devise-token_authenticatable'
gem 'ruby-ldap'
gem 'rabl'
gem 'simpleidn'

gem 'acts_as_list'
gem 'state_machine'
gem 'dynamic_form'

gem 'protected_attributes_continued' # attr_accessible backport
gem 'activemodel-serializers-xml'
gem 'rails-controller-testing'

gem 'nokogiri'

gem 'bootsnap'

group :development, :test do
  gem "rspec-rails"
  gem 'rspec-collection_matchers'
  gem 'rspec-html-matchers' # legacy matchers

  gem 'listen'
end

group :test do
  gem "factory_bot_rails"

  gem "turnip" # run gherkin (cucumber) features in rspec

  gem 'pry'
  gem 'pry-byebug'

  gem 'capybara'
  gem 'database_cleaner'

  gem 'simplecov', require: false
end

group :development, :deploy do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'rvm-capistrano', require: false
end
