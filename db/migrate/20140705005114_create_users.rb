class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text    :name
      t.boolean :available, default: true

      t.timestamps
    end
  end
end
