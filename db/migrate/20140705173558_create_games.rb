class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :initiator_id
      t.integer :opponent_id
      t.boolean :opponent_accepted, default: false
      t.integer :turn_id
      t.integer :winner_id
      
      t.timestamps
    end
  end
end
