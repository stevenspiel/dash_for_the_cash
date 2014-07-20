class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.integer :position
      t.integer :game_id
      t.integer :player_id

      t.timestamps
    end
  end
end
