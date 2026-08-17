# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in gemtest.gemspec
gemspec

ruby_version = Gem::Version.new(ENV.fetch('EARTHLY_RUBY_VERSION'))
rails_min_version = ENV.fetch('EARTHLY_RAILS_VERSION')

# ORMs
gem 'activerecord', "~> #{rails_min_version}"
# gem 'bson_ext', '~> 1.3'

# Tests
gem 'capybara'
gem 'capybara-screenshot'
gem 'database_cleaner-active_record'
gem 'factory_girl_rails'
gem 'mocha', '~> 0.13.0'
# With Ruby >= 3.0
if ruby_version >= Gem::Version.new('3.0.0')
  if Gem::Version.new(rails_min_version) < Gem::Version.new('7.0.0')
    gem 'nokogiri', '~> 1.13.0'
  else
    gem 'nokogiri', '~> 1.15.0'
  end
else
  gem 'nokogiri', '~> 1.12.0'
end
gem 'responders'
gem 'rubocop'
gem 'shoulda'
# minitest 6 (requires Ruby >= 3.2) is incompatible with Rails 7.2's test runner;
# pin to 5.x. See https://github.com/minitest/minitest/issues/1045
gem 'minitest', '< 6'
if Gem::Version.new(rails_min_version) >= Gem::Version.new('6.0.0')
  gem 'sqlite3', '~> 1.4'
else
  gem 'sqlite3', '~> 1.3.13'
end
gem 'test-unit'
gem 'timecop'

# With Ruby >= 3.0
if ruby_version >= Gem::Version.new('3.0.0')
  gem 'base64'
  gem 'bigdecimal'
  gem 'drb'
  gem 'mutex_m'
  # observer became a bundled (non-default) gem in Ruby 3.4; factory_girl requires
  # it but does not declare the dependency. Add it so the require resolves to the gem.
  # See https://stdgems.org/observer/
  gem 'observer'
end

# gem 'debugger'
