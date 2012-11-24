class Track < ActiveRecord::Base
  attr_accessible :title, :track_url, :playlist_id, :position, :artwork_url, :duration
  
  belongs_to :playlist
  
  validates :title,       :presence => true
  validates :track_url,   :presence => true
  validates :artwork_url, :presence => true
  validates :duration,    :presence => true
  validates :playlist,    :presence => true
  validates :position,    :presence     => true, 
                          :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, 
                          :uniqueness   => { :scope => :playlist_id }
  

  
end
