mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ToolNodeView extends View
  
  initialize: ->
    super
    console.log 'Initializing ToolNodeView'
    @mode = 'node'
    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-node').addClass('active')
    mediator.outer.attr('cursor', 'crosshair')
    
    @delegate 'click', '#canvas_background', @create_node

  remove: ->
    # Unbind delgated events ------
    @$el.off 'click', '#canvas_background'
    
    # Unbind @el ------------------
    @setElement('')
    
    console.log '[xx Node tool out! xx]'
    super

  create_node: (e) ->
    mediator.nodes.create x: e.offsetX, y: e.offsetY