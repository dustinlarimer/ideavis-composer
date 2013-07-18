mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ToolNodeView extends View
  
  initialize: ->
    super
    console.log 'Initializing ToolNodeView'    
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
    mediator.outer.attr('cursor', 'default')
    super

  create_node: (e) ->
    mediator.nodes.create {x: e.pageX-50, y: e.pageY-50}, {wait: true}