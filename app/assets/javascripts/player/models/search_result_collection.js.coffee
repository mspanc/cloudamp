# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # This model stores track collection of a search result.
  #
  # It uses custom synchronization method, by overriding default that comes
  # from Backbone in order to fetch data from SoundCloud instead of our Rails app.
  #
  # For track collection of a Playlist please see TrackCollection
  # model.
  class CloudAmp.Models.SearchResultCollection extends Backbone.Collection
    model: CloudAmp.Models.Track

    # Override default sync method to build collection based on results from
    # the SoundCloud search API.
    # 
    # This is called internally by CloudAmp.Models.SearchResultCollection#fetch.
    #
    # @param method CRUD method for synchronization, only "read" is supported
    # @param model model that sync applies to
    # @param options object with options, must have a key "query" that is non empty
    #        and contains search query
    sync: (method, model, options) =>
      throw new CloudAmp.Errors.CollectionReadOnly(method) unless method == "read"
      throw new CloudAmp.Errors.OptionMissing("query") if typeof(options.query) == "undefined"
      throw new CloudAmp.Errors.VariableMustNotBeEmpty("options.query") if options.query.trim() == ""
            
      SC.get "/tracks", { q: options.query }, (tracks) ->
        # Remove tracks that are not streamable
        stripped_tracks = tracks.filter (track) =>
          track.streamable == true

        # Strip unnecessary attributes, save the memory!
        stripped_tracks = stripped_tracks.map (track) =>
          seconds = track.duration / 1000
          minutes = seconds / 60
          seconds = seconds % 60
          hours   = minutes / 60
          minutes = minutes % 60
          human_duration = "%02d:%02d:%02d".sprintf parseInt(hours), parseInt(minutes), parseInt(seconds)
        
          artwork_url : track.artwork_url
          title       : track.title
          track_url   : track.uri
          duration    : human_duration
      
        # Notify that we had successfully fetched search results
        options.success stripped_tracks

        


