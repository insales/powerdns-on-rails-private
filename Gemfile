source 'https://rubygems.org'

gem 'rails', '3.2.22.5'

gem 'unicorn'

group :assets do
  # asset pipeline же не используется?
  # gem 'sass-rails'
  # gem 'coffee-rails'
  # gem 'uglifier'
end

platforms :ruby do
  gem 'pg', '>= 0.9.0'
  # gem 'therubyracer'
end

# for rails 3.2
gem 'iconv'
gem 'rake', '< 11.0'
gem 'test-unit', '~> 3.0'
# end

gem 'haml'
gem 'jquery-rails'
gem 'will_paginate', '~> 3.0.3'
gem "audited-activerecord", "~> 3.0.0.rc2"
gem 'inherited_resources'
gem 'devise', '2.2.3'
gem "devise-encryptable"
gem 'ruby-ldap'
gem 'rabl'
gem 'simpleidn'

gem 'acts_as_list'
gem 'state_machine'
gem 'dynamic_form'

group :development, :test do
  gem "rspec-rails"
  gem 'rspec-collection_matchers'
  gem 'rspec-html-matchers' # legacy matchers
  # gem 'RedCloth', '>= 4.1.1'
end

group :test do
  # gem "factory_girl_rails", "~> 3.0" #TODO: 4.0
  gem "factory_girl_rails", "~> 4.9.0" #TODO: migrate to factory_bot

  gem 'pry', '~>0.11.0' # для старых рельсов
  gem 'pry-byebug'

  gem "cucumber-rails", :require => false
  gem 'database_cleaner'

  gem 'simplecov', require: false
end

group :development, :deploy do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'rvm-capistrano', require: false
end
