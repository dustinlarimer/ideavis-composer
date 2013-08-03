mediator = require 'mediator'
View = require 'views/base/view'

zoom_helpers = require '/editor/lib/zoom-helpers'

module.exports = class ToolNodeView extends View
  
  initialize: ->
    super
    console.log 'Initializing ToolNodeView'    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-node').addClass('active')
    
    mediator.outer.attr('cursor', 'crosshair')
    d3.select('#canvas_elements_background')
      .call(d3.behavior.drag()
        .on('dragend', @create_node))

    @subscribeEvent 'node_created', @activate
    @activate()

  activate: =>
    @nodes = d3.selectAll('g.nodeGroup').attr('pointer-events', 'none')
    @links = d3.selectAll('g.linkGroup').attr('pointer-events', 'none')

  remove: ->
    mediator.outer.attr('cursor', 'default')
    d3.select('#canvas_elements_background')
      .call(d3.behavior.drag()
        .on('dragend', null))
    
    @nodes.attr('pointer-events', 'all')
    @links.attr('pointer-events', 'visibleStroke')
    @nodes = null
    @links = null
    # Unbind @el ------------------
    @setElement('')
    super

  create_node: =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = zoom_helpers.get_coordinates(e)
    mediator.nodes.create {x: coordinates.x, y: coordinates.y}, {wait: true}
