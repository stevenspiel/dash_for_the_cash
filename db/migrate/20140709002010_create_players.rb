class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :user
      t.references :game
      t.integer :position,      null: false, default: 0
      t.boolean :ready,         null: false, default: false
      t.boolean :winner,        null: false, default: false
      t.boolean :defend,        null: false, default: false

      t.timestamps
    end
  end
end
