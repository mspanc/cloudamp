#
# This code appends header with CSRF token to every non-GET XHR request.
#
# For more information about CSRF protection please refer to Ruby on Rails 
# documentation
#
$.ajaxSetup
  beforeSend: (xhr, settings) ->
    return if (settings.crossDomain)
    return if (settings.type == "GET")
    if (app.csrf_token)
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
