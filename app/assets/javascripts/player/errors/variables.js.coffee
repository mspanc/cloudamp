class CloudAmp.Errors.VariableMustNotBeEmpty extends Error
  name:    "CloudAmp.Errors.VariableMustNotBeEmpty"
  message: "Variable must not be empty"
  
  constructor: (variable_name) ->
    @message = "Variable " + variable_name + " must not be empty"
    
    
class CloudAmp.Errors.OptionMissong extends Error
  name:    "CloudAmp.Errors.OptionMissing"
  message: "Option is missing"
  
  constructor: (option_name) ->
    @message = "Key options." + option_name + " is missing"    
