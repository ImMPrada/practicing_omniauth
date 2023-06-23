class CreateServices < ActiveRecord::Migration[7.0]
  def change
    create_table :services do |t|
      t.string :uid, null: false, index: { unique: true }
      t.string :provider, null: false
      t.string :expires, null: false, default: false
      t.date :expires_at
      t.string :token, null: false, default: ""

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
