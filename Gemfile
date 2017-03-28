source 'http://rubygems.org'

group :production, :development, :test do
  gem 'rails', '3.2.19'
end

group :production do
  gem 'unicorn'
end

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

platforms :ruby do
  gem 'pg', '>= 0.9.0'
  gem 'therubyracer'
end

group :production, :development, :test do
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
end

group :development, :test do
  gem "rspec-rails"
  gem 'RedCloth', '>= 4.1.1'
end

group :test do
  gem 'ruby-debug19'
  gem "factory_girl_rails", "~> 3.0" #TODO: 4.0

  gem "cucumber-rails", :require => false
  gem 'mocha', :require => false
  gem 'webrat'
  gem 'database_cleaner'
end

group :development, :deploy do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'rvm-capistrano'
end
