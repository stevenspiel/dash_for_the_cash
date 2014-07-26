class CreateTraps < ActiveRecord::Migration
  def change
    create_table :traps do |t|
      t.integer :player_id
      t.integer :position, null: false
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
