class Track < ActiveRecord::Base
  attr_accessible :title, :track_url, :playlist_id, :artwork_url, :duration
  
  belongs_to :playlist
  
  validates :title,       :presence => true
  validates :track_url,   :presence => true
  validates :duration,    :presence => true
  validates :playlist,    :presence => true
  validates :position,    :presence     => true, 
                          :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, 
                          :uniqueness   => { :scope => :playlist_id }
  


  before_validation :generate_next_position
  
  protected
  
  def generate_next_position
    last_track = Track.where(:playlist_id => self.playlist_id).select(:position).order("position DESC").first
    
    if last_track
      self.position = last_track.position + 1
    else
      last_position = 0
    end
  end
end
