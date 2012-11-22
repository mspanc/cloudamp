class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer   :soundcloud_id, :null => false
      t.timestamps
    end
    
    add_index :users, :soundcloud_id, :unique => true
  end
end
