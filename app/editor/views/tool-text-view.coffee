mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ToolTextView extends View
  
  initialize: ->
    super
    console.log '[-- Text tool activated --]'
    @mode = 'text'
    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-text').addClass('active')
    mediator.outer.attr('cursor', 'text')

  remove: ->
    # @$el.off 'event', '#selector'
    # Remove d3 handlers
    @setElement('')
    
    console.log '[xx Text tool out! xx]'
    super