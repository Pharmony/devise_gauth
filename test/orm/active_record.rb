# frozen_string_literal: true

if ENV.fetch('CI', nil)
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
end

migration_scripts_path = File.expand_path('../rails_app/db/migrate/', __dir__)

if Rails.version < '5.2'
  ActiveRecord::Migrator.migrate(migration_scripts_path)
elsif Rails.version >= '5.2' && Rails.version < '6.0'
  ActiveRecord::MigrationContext.new(migration_scripts_path).migrate
else
  ActiveRecord::MigrationContext.new(
    migration_scripts_path,
    ActiveRecord::Base.connection.schema_migration
  ).migrate
end
