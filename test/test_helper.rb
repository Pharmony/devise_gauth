# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
DEVISE_ORM = (ENV['DEVISE_ORM'] || :active_record).to_sym

$:.unshift File.dirname(__FILE__)
puts "\n==> Devise.orm = #{DEVISE_ORM.inspect}"
require 'rails_app/config/environment'

if Gem::Version.new(Devise::VERSION) >= Gem::Version.new('4.2.0')
  # include Devise::Test::ControllerHelpers
else
  include Devise::TestHelpers
end

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

I18n.load_path << File.expand_path('../support/locale/en.yml', __FILE__) if DEVISE_ORM == :mongoid

ActiveSupport::Deprecation.silenced = true

class ActionDispatch::IntegrationTest
  include Capybara::DSL
end

class ActionController::TestCase
  if Gem::Version.new(Devise::VERSION) >= Gem::Version.new('4.2.0')
    include Devise::Test::ControllerHelpers
  else
    include Devise::TestHelpers
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

class Minitest::Test
  include AroundEachTest
end
