class NeedAtLeastOnePlaylistError < Exception
end

class Playlist < ActiveRecord::Base
  attr_accessible :title, :description, :position
  
  belongs_to :user
  has_many   :tracks,  :order => "position ASC", :dependent => :destroy
  
  validates :user,     :presence     => true
  validates :title,    :presence     => true,
                       :length       => { :minimum => 1 }
  validates :position, :presence     => true, 
                       :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }, 
                       :uniqueness   => { :scope => :user_id }
                       
  
  before_destroy    :ensure_we_dont_delete_last_playlist
  before_validation :set_last_position, :on => :create
  
  scope :ordered,            :order => "position ASC"
  
  
  protected
  
  def set_last_position
    greatest_position = user.playlists.select(:position).order("position DESC").first
    if greatest_position.nil?
      self.position = 0
    else
      self.position = greatest_position.position + 1
    end
  end
  
  def ensure_we_dont_delete_last_playlist
    raise NeedAtLeastOnePlaylistError, "I won't delete last playlist" if user.playlists.count == 1
  end
end
