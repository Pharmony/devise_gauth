# frozen_string_literal: true

class DeviseGauthAddToUsers < ActiverecordMigrationKlass
  def self.up
    change_table :users do |t|
      t.string  :gauth_secret, :gauth_token
      t.string  :gauth_enabled, default: Rails.version >= '5.2' ? 0 : 'f'
      t.string  :gauth_tmp
      t.datetime :gauth_tmp_datetime
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :gauth_secret, :gauth_enabled, :gauth_tmp, :gauth_tmp_datetime
    end
  end
end
