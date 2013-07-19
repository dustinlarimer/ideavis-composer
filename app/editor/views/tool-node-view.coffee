mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ToolNodeView extends View
  
  initialize: ->
    super
    console.log 'Initializing ToolNodeView'    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-node').addClass('active')
    mediator.outer.attr('cursor', 'crosshair')
    
    @delegate 'click', '#canvas_elements_background', @create_node
    @subscribeEvent 'node_created', @activate
    @activate()

  activate: =>
    @nodes = d3.selectAll('g.nodeGroup').attr('pointer-events', 'none')
    @links = d3.selectAll('g.linkGroup').attr('pointer-events', 'none')

  remove: ->
    # Unbind delgated events ------
    @$el.off 'click', '#canvas_elements_background'
    
    @nodes.attr('pointer-events', 'all')
    @links.attr('pointer-events', 'visibleStroke')
    
    # Unbind @el ------------------
    @setElement('')
    
    console.log '[xx Node tool out! xx]'
    mediator.outer.attr('cursor', 'default')
    super

  create_node: (e) ->
    mediator.nodes.create {x: e.pageX-50, y: e.pageY-50}, {wait: true}