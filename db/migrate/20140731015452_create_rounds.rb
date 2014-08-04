class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.integer :game_id
      t.integer :first_player_id
      t.integer :second_player_id

      t.timestamps
    end
  end
end
