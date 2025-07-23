# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
DEVISE_ORM = (ENV['DEVISE_ORM'] || :active_record).to_sym

$:.unshift File.dirname(__FILE__)
puts "\n==> Devise.orm = #{DEVISE_ORM.inspect}"
require 'rails_app/config/environment'

if Gem::Version.new(Devise::VERSION) >= Gem::Version.new('4.2.0')
  # include Devise::Test::ControllerHelpers
else
  include Devise::TestHelpers # rubocop:disable Style/MixinUsage
end

# Destroys the existing database file before running the suite to prevent issue
# when switching Rails versions.
test_db_filepath = File.expand_path('rails_app/db/test.sqlite3', __dir__)
File.exist?(test_db_filepath) && FileUtils.rm_f(test_db_filepath)

require "orm/#{DEVISE_ORM}"
require 'rails/test_help'
require 'capybara/rails'
require 'database_cleaner/active_record'
if Rails.version < '4'
  require 'capybara-screenshot/testunit'
else
  require 'capybara-screenshot/minitest'
end
require 'timecop'

I18n.load_path << File.expand_path('support/locale/en.yml', __dir__) if DEVISE_ORM == :mongoid

module ActionDispatch
  class IntegrationTest
    include Capybara::DSL
  end
end

module ActionController
  class TestCase
    if Gem::Version.new(Devise::VERSION) >= Gem::Version.new('4.2.0')
      include Devise::Test::ControllerHelpers
    else
      include Devise::TestHelpers
    end
  end
end

DatabaseCleaner.strategy = :truncation

module AroundEachTest
  def before_setup
    super
    DatabaseCleaner.start
  end

  def after_teardown
    super
    DatabaseCleaner.clean
  end
end

module Minitest
  class Test
    include AroundEachTest
  end
end
