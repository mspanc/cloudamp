class User < ActiveRecord::Base
  # Helper function that is used for storing local user accounts
  # and match them with SoundCloud accounts.
  #
  # It just seeks for existing account with passed SoundCloud ID
  # or creates one if it does not exist.
  #
  # * *Parameters* :
  #   - +soundcloud_id+ -> user's SoundCloud ID
  # * *Return* :
  #   - record of class User representing user associated with passed ID
  # * *Throws* :
  #   - ActiveRecord's exceptions if creation of new record failed 
  def self.find_or_create_by_soundcloud_id(soundcloud_id)
    self.transaction do
      # Return existing record for a user if it exists
      user = self.where(:soundcloud_id => soundcloud_id).first
      return user if user
      
      # Create new record for a user if does not exist
      user = self.new
      user.soundcloud_id = soundcloud_id
      user.save!
      
      user
    end
  end
end
