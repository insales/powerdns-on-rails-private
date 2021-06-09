source 'https://rubygems.org'

gem 'rails', '4.2.11.3'
# ruby 2.3 - на проде (powerdnsapp3/6) уже есть (не забыть что нужен полный рестарт при смене рубей)
# gem 'rails', '5.0.7.2'
# gem 'rails', '5.1.7'
# gem 'rails', '5.2.6'
# ruby 2.5
# ruby 2.6 - тоже есть на проде
# gem 'rails', '6.0.3.7'
# gem 'rails', '6.1.3.2'

gem 'unicorn'

group :assets do
  # asset pipeline же не используется?
  # gem 'sass-rails'
  # gem 'coffee-rails'
  # gem 'uglifier'
end

platforms :ruby do
  gem 'pg', '~> 0.11'
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
gem "audited-activerecord", "4.0"
gem 'inherited_resources'
gem 'devise', '~>3.0'
gem "devise-encryptable"
gem 'devise-token_authenticatable'
gem 'ruby-ldap'
gem 'rabl'
gem 'simpleidn'

gem 'acts_as_list'
gem 'state_machine'
gem 'dynamic_form'

gem 'protected_attributes' # attr_accessible backport

group :development, :test do
  gem "rspec-rails"
  gem 'rspec-collection_matchers'
  gem 'rspec-html-matchers' # legacy matchers
end

group :test do
  gem "factory_bot_rails", "~> 4.9"

  gem "turnip" # run gherkin (cucumber) features in rspec

  gem 'pry', '~>0.11.0' # для старых рельсов
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
