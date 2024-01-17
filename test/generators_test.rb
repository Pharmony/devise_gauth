# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'test_helper'
require 'rails/generators'
require 'generators/devise_gauth/devise_gauth_generator'

class GeneratorsTest < ActiveSupport::TestCase
  RAILS_APP_PATH = File.expand_path('rails_app', __dir__)

  test 'rails g should include the 3 generators' do
    @output = `cd #{RAILS_APP_PATH} && rails g`
    assert @output.match(%r|DeviseGauth:\n  devise_gauth\n  devise_gauth:install\n  devise_gauth:views|)
  end

  test 'rails g devise_gauth:install' do
    @output = `cd #{RAILS_APP_PATH} && rails g devise_gauth:install -p`
    assert @output.match(%r^(inject|insert).+config/initializers/devise\.rb\n^)
    assert @output.match(%r|create.+config/locales/devise\.gauth\.en\.yml\n|)
  end
end
