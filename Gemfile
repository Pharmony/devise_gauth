# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

rails_min_version = ENV.fetch('EARTHLY_RAILS_VERSION', '3.2.22.5')
rails_max_version = (rails_min_version.split('.').first.to_i + 1).to_s

# ORMs
gem 'activerecord', "~> #{rails_min_version}", "< #{rails_max_version}"
# gem 'bson_ext', '~> 1.3'

# Tests
gem 'capybara'
gem 'capybara-screenshot'
gem 'database_cleaner-active_record'
gem 'factory_girl_rails'
gem 'mocha', '~> 0.13.0'
gem 'nokogiri'
gem 'responders'
gem 'rubocop'
gem 'shoulda'
gem 'sqlite3', '~> 1.3.13'
gem 'test-unit'
gem 'timecop'
# gem 'debugger'
