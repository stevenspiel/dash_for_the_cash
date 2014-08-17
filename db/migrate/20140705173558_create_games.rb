class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :initiator_id
      t.integer :opponent_id
      t.boolean :opponent_ready, default: false
      t.integer :winner_id
      t.integer :wager, default: 1
      
      t.timestamps
    end
  end
end
