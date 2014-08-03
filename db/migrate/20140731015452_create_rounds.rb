class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.integer :game_id
      t.integer :first_player
      t.integer :second_player

      t.timestamps
    end
  end
end
