#
# Class responsible for storing RoR application settings
#
# Settigns are stored in config/application.yml
#
# It uses settingslogic gem to handle parsing config file.
#
# You can treat Settings class as a Hash or Object, so
# both calls shown below are valid:
#
#   Settings.soundcloud.app.client_id
#   Settings["soundcloud"]["app"]["client_id"]
#
# Please refer to settingslogic documentation for more
# instructions.
#
class Settings < Settingslogic
  source File.join(Rails.root, "config", "application.yml")
  namespace Rails.env
end

