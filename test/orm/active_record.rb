# frozen_string_literal: true

if ENV.fetch('CI', nil)
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
end

migration_scripts_path = File.expand_path('../rails_app/db/migrate/', __dir__)

# Rails 4.2.x until 5.1.x
if Rails.version < '5.2'
  puts "Running migration scripts BEFORE Rails 5.2 (Version: #{Rails.version})"
  ActiveRecord::Migrator.migrate(migration_scripts_path)
# Rails 5.2.x
elsif Rails.version >= '5.2' && Rails.version < '6.0'
  puts "Running migration scripts for Rails 5.2 (Version: #{Rails.version})"
  ActiveRecord::MigrationContext.new(migration_scripts_path).migrate
# Rails 6.x until 7.0.x
elsif Rails.version >= '6.0' && Rails.version < '7.1'
  puts "Running migration scripts for Rails 6 and 7.0.x (Version: #{Rails.version})"
  ActiveRecord::MigrationContext.new(
    migration_scripts_path,
    ActiveRecord::Base.connection.schema_migration
  ).migrate
# Rails 7.1.x and higher
else
  puts "Running migration scripts for Rails 7.1 and higher (Version: #{Rails.version})"
  ActiveRecord::MigrationContext.new(migration_scripts_path).migrate
end
