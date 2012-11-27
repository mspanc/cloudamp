# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # Error thrown if certain variable was expected not to be empty.
  # Currently used only in new/edit playlist forms.
  class CloudAmp.Errors.VariableMustNotBeEmpty extends Error
    name:    "CloudAmp.Errors.VariableMustNotBeEmpty"
    message: "Variable must not be empty"
    
    constructor: (variable_name) ->
      @message = "Variable " + variable_name + " must not be empty"
      

  # Error thrown if we expected certain options to be passed to our function.
  # We assume in error message that the variable name were "options".
  class CloudAmp.Errors.OptionMissing extends Error
    name:    "CloudAmp.Errors.OptionMissing"
    message: "Option is missing"
    
    constructor: (option_name) ->
      @message = "Key options." + option_name + " is missing"    
