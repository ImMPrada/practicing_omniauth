class AddColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string, null: false, unique: true
    add_column :users, :avatar_url, :string, null: false
  end
end
