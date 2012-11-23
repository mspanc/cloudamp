class NeedAtLeastOnePlaylistError < Exception
end

class Playlist < ActiveRecord::Base
  attr_accessible :title, :description, :position
  
  belongs_to :user
  
  validates :user,     :presence     => true
  validates :title,    :presence     => true,
                       :length       => { :minimum => 1 }
  validates :position, :presence     => true, 
                       :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, 
                       :uniqueness   => { :scope => :user_id }
                       
  
  before_destroy :ensure_we_dont_delete_last_playlist
  before_create  :set_last_position
  
  scope :ordered,            :order => "position ASC"
  scope :filtered_for_views, :select => [ :id, :title, :description ]
  
  protected
  
  def set_last_position
    greatest_position = user.playlists.select(:position).order("position DESC").first
    if greatest_position.nil?
      position = 0
    else
      position = greatest_position.position + 1
    end
  end
  
  def ensure_we_dont_delete_last_playlist
    raise NeedAtLeastOnePlaylistError, "I won't delete last playlist" if user.playlists.count == 1
  end
end
