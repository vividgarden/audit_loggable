# frozen_string_literal: true

class CreateAllTables < ActiveRecord::Migration::Current
  def self.up
    create_table(:users) do |t|
      t.string :name
      t.string :email
      t.string :password

      t.date :created_on
      t.date :updated_on

      t.timestamps
    end

    create_table(:posts) do |t|
      t.integer :user_id
      t.integer :number
      t.string :title
      t.string :body
      t.integer :status

      t.string :type

      t.integer :lock_version, default: 0

      t.date :created_on
      t.date :updated_on

      t.timestamps
    end

    create_table(:comments) do |t|
      t.integer :post_id
      t.integer :user_id
      t.integer :number
      t.string :body

      t.string :type

      t.integer :lock_version, default: 0

      t.date :created_on
      t.date :updated_on

      t.timestamps
    end
  end
end

ActiveRecord::Migration.verbose = false
CreateAllTables.up
