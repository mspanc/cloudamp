# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # View responsible for handling playlist tabs.
  class CloudAmp.Views.PlaylistTab extends Backbone.View
    template : _.template($('#playlist-tab-template').html()),
    tagName  : "li"
    
    initialize: ->
      @model.on  "destroy",            @remove, @
      @model.on  "change:title",       @on_title_changed
      @model.on  "change:description", @on_description_changed
      
    teardown: ->
      @model.off "destroy",            @remove, @
      @model.off "change:title",       @on_title_changed
      @model.off "change:description", @on_description_changed
      
      
      
    on_title_changed: (model, value, options) =>
      @$("a[data-toggle=tab]").text value
    
    
    on_description_changed: (model, value, options) =>
      @$el.children("a[rel=tooltip]")
        .attr("data-original-title", value)
      
    
    render: ->
      @$el.html(@template(@model.toJSON()))
      @$el.children("a[rel=tooltip]").tooltip()
      return @
      
    
