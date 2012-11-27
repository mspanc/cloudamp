# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # Error thrown if something was wrong in the UI logic, and SoundCloud player
  # widget loaded different track than we expected.
  class CloudAmp.Errors.UnexpectedTrackStateChange extends Error
    name:    "CloudAmp.Errors.UnexpectedTrackStateChange"
    message: "Unexpected track has changed state"
    
    constructor: (received_track_url, expected_track_url) ->
      @message = "Track " + received_track_url + " has changed state, but expected one was " + expected_track_url
    
    
  # Error thrown if something was wrong in the UI logic, and it tries to 
  # change track's state in wrong order.
  class CloudAmp.Errors.InvalidTrackStateTransition extends Error
    name:    "CloudAmp.Errors.InvalidTrackStateTransition"
    message: "Unable to perform such track state transition"
    
    constructor: (track_url, current_state, desired_state) ->
      @message = "Unable to make track state transition " + current_state + " => " + desired_state + " for track " + track_url
      
      

