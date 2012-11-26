class RemoveUniqueIndexFromTrackPositions < ActiveRecord::Migration
  def up
    remove_index :tracks, [ :playlist_id, :position ]  
    add_index :tracks, [ :playlist_id, :position ]
  end

  def down
    remove_index :tracks, [ :playlist_id, :position ]  
    add_index :tracks, [ :playlist_id, :position ], :unique => true
  end
end
