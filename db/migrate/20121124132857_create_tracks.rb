class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.belongs_to :playlist,        :null => false
      t.string     :title,           :null => false
      t.string     :track_url,       :null => false
      t.integer    :position,        :null => false, :default => 0

      t.timestamps
    end

    add_foreign_key :tracks, :playlists
    
    add_index :tracks, [ :playlist_id, :position ], :unique => true
  end
end
