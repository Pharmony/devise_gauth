# frozen_string_literal: true

require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class DeviseGauthGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_devise_migration
        migration_template 'migration.rb', "db/migrate/devise_gauth_add_to_#{table_name}.rb"
      end
    end
  end
end
