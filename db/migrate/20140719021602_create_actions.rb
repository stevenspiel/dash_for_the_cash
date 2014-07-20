class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string  :action
      t.integer :game_id
      t.integer :player_id
      
      t.timestamps
    end
  end
end
