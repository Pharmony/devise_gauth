# frozen_string_literal: true

class CreatePosts < ActiverecordMigrationKlass
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body

      if Rails.version < '5'
        t.timestamps
      else
        t.timestamps null: true
      end
    end
  end
end
