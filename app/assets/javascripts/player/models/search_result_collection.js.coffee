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
#    throw new CloudAmp.Errors.CollectionReadOnly(method) unless method == "read"
#    throw new CloudAmp.Errors.OptionMissing("query") if typeof(options.query) == "undefined"
#    throw new CloudAmp.Errors.VariableMustNotBeEmpty("options.query") if options.query.trim() == ""
          
          
    # TODO add error handling
#    SC.get "/tracks", { q: options.query }, (tracks) ->
#      # Remove tracks that are not streamable
#      stripped_tracks = tracks.filter (track) =>
#        track.streamable == true
#
#      # Strip unnecessary attributes, save the memory!
#      stripped_tracks = stripped_tracks.map (track) =>
#        artwork_url : track.artwork_url
#        title       : track.title
#        track_url   : track.uri
#    
#      # Notify that we had successfully fetched search results
#      options.success stripped_tracks

      options.success [{ artwork_url : "http://i1.sndcdn.com/artworks-000009071938-r6wua2-large.jpg?80d2906", title : "Katy Perry", track_url: "http://123" }, { artwork_url : "http://i1.sndcdn.com/artworks-000018747391-0w3itu-large.jpg?80d2906", title : "Katy fas12378", track_url: "http://123" }, { artwork_url : "http://i1.sndcdn.com/artworks-000010597607-rv7406-large.jpg?80d2906", title : "XjDHASJKJK", track_url: "http://123" } ]
      

