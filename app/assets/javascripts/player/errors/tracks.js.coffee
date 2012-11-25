class CloudAmp.Errors.UnexpectedTrackStateChange extends Error
  name:    "CloudAmp.Errors.UnexpectedTrackStateChange"
  message: "Unexpected track has changed state"
  
  constructor: (received_track_url, expected_track_url) ->
    @message = "Track " + received_track_url + " has changed state, but expected one was " + expected_track_url
    
    
class CloudAmp.Errors.InvalidTrackStateTransition extends Error
  name:    "CloudAmp.Errors.InvalidTrackStateTransition"
  message: "Unable to perform such track state transition"
  
  constructor: (current_state, desired_state) ->
    @message = "Unable to make track state transition " + current_state + " => " + desired_state
    
    

