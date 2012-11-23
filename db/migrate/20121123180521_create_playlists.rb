class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.belongs_to :user,        :null => false
      t.string     :title,       :null => false
      t.string     :description
      t.integer    :position,    :null => false, :default => 0
      t.timestamps
    end
    
    add_foreign_key :playlists, :users
    
    add_index :playlists, [ :user_id, :position ], :unique => true
  end
end
