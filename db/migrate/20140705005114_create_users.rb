class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :money,           default: 1
      t.integer :tier_preference, default: 1
      t.string :provider
      t.string :uid
      t.string :oauth_token
      t.datetime :oauth_expires_at
      t.boolean :available, default: false

      t.timestamps
    end
  end
end
