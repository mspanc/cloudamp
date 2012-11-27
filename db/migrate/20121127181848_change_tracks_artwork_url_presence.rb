class ChangeTracksArtworkUrlPresence < ActiveRecord::Migration
  def up
    change_column_null :tracks, :artwork_url, true
  end

  def down
    change_column_null :tracks, :artwork_url, false
  end
end
