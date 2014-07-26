class CreateBasePositions < ActiveRecord::Migration
  def change
    create_table :base_positions do |t|
      t.integer :position, null: false, default: 0
      t.integer :player_id

      t.timestamps
    end
  end
end
