# frozen_string_literal: true

module DeviseGauth
  module Orm
    # This module contains handle schema (migrations):
    #
    #  create_table :accounts do |t|
    #    t.gauth_secret
    #    t.gauth_enabled
    #  end
    #

    module ActiveRecord
      module Schema
        include DeviseGauth::Schema
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::Table.send :include, DeviseGauth::Orm::ActiveRecord::Schema
ActiveRecord::ConnectionAdapters::TableDefinition.send :include, DeviseGauth::Orm::ActiveRecord::Schema
