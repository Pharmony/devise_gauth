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
  elsif ruby_version <= Gem::Version.new('3.2')
    gem 'nokogiri', '~> 1.18.10'
  else
    gem 'nokogiri', '~> 1.19.0' # rubocop:disable Bundler/DuplicatedGem
  end
else
  gem 'nokogiri', '~> 1.12.0' # rubocop:disable Bundler/DuplicatedGem
end
gem 'responders'
if ruby_version <= Gem::Version.new('2.7')
  gem 'rubocop', '< 1.70'
else
  gem 'rubocop'
end
# rubocop-ast 1.52+ depends on prism with an open constraint, and prism 2.x only
# ships precompiled platform gems (gnu and musl) that require Ruby >= 3.3: the
# resolver on the Ruby 2.7 - 3.2 matrix legs picks those and fails with e.g.
# "prism-2.1.0-aarch64-linux-musl requires ruby version >= 3.3". Keep those legs
# on prism 1.x, which is pure Ruby and requires only Ruby >= 2.7. Legs on Ruby
# < 2.7 resolve a prism-less rubocop-ast instead, since prism needs Ruby >= 2.7.
if ruby_version >= Gem::Version.new('2.7.0') &&
   ruby_version < Gem::Version.new('3.3.0')
  gem 'prism', '< 2.0'
end
gem 'shoulda'
# minitest 6 (requires Ruby >= 3.2) is incompatible with Rails 7.2's test runner;
# pin to 5.x. See https://github.com/minitest/minitest/issues/1045
gem 'minitest', '< 6'
if Gem::Version.new(rails_min_version) >= Gem::Version.new('8.0.0')
  gem 'sqlite3', '~> 2.1'
elsif Gem::Version.new(rails_min_version) >= Gem::Version.new('6.0.0')
  gem 'sqlite3', '~> 1.4'
else
  gem 'sqlite3', '~> 1.3.13'
end

# ActiveSupport 8.0.x still passes `quirks_mode: true` to `JSON.generate`
# (lib/active_support/json/encoding.rb), an option the json 3.x gem removed:
# signing a cookie (`cookies.signed[...] = ...`) then fails with
# "ArgumentError: unknown keyword: quirks_mode". Rails 8.1 dropped the
# option. json 3.x only enters the bundle through the test-only rubocop
# dependency, so pin the 2.x series for the Rails 8.0.x legs.
if (Gem::Version.new(rails_min_version) >= Gem::Version.new('8.0.0') &&
   Gem::Version.new(rails_min_version) < Gem::Version.new('8.1.0')) ||
   ruby_version <= Gem::Version.new('3.2')
  gem 'json', '~> 2.0'
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
