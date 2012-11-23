$ ->
  class CloudAmp.Errors.CollectionReadOnly extends Error
    name:    "CloudAmp.Errors.CollectionReadOnly"
    message: "SearchResultCollection is read-only, the only supported method is \"read\""
    
    constructor: (passed_method) ->
      @message = "SearchResultCollection is read-only, method passed was \"" + passed_method + "\" while the only supported method is \"read\""
