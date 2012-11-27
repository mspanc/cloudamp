# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # Error thrown if you try to write to read-only collections. Currently applies
  # only to SearchResult model.
  class CloudAmp.Errors.CollectionReadOnly extends Error
    name:    "CloudAmp.Errors.CollectionReadOnly"
    message: "SearchResultCollection is read-only, the only supported method is \"read\""
    
    constructor: (passed_method) ->
      @message = "SearchResultCollection is read-only, method passed was \"" + passed_method + "\" while the only supported method is \"read\""
