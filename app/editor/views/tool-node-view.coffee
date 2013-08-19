mediator = require 'mediator'
View = require 'views/base/view'

Path = require 'models/path'
Text = require 'models/text'

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
        .on('dragstart', @start_node)
        .on('drag', @scale_node)
        .on('dragend', @create_node))

    @ghost_node = null
    @start_point = null
    @end_point = null

    @subscribeEvent 'node_created', @activate
    @activate()

  activate: =>
    @nodes = d3.selectAll('g.nodeGroup').attr('pointer-events', 'none')
    @links = d3.selectAll('g.linkGroup').attr('pointer-events', 'none')

  remove: ->
    mediator.outer.attr('cursor', 'default')
    d3.select('#canvas_elements_background')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
    @reset()
    @nodes.attr('pointer-events', 'all')
    @links.attr('pointer-events', 'visibleStroke')
    @nodes = null
    @links = null
    
    @setElement('')
    super

  reset: =>
    @ghost_node?.remove()
    @start_point = null
    @end_point = null



  start_node: =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = zoom_helpers.get_coordinates(e)
    @start_point=
      x: Math.round(coordinates.x)
      y: Math.round(coordinates.y)
    @ghost_node = mediator.controls.selectAll('g#newNode')
      .data([@start_point])
    @ghost_node
      .enter()
      .append('svg:g')
        .attr('id', '#newNode')
        .append('svg:circle')
          .attr('id', 'ghost_node')
          .attr('cx', (d)-> return d.x)
          .attr('cy', (d)-> return d.y)
          .attr('r', 0)
          .attr('fill', 'none')
          .attr('stroke', '#000')
          .attr('stroke-dasharray', '5,4')
          .attr('stroke-opacity', .5)
          .attr('stroke-width', 1)
    @ghost_node
      .exit()
      .remove()



  scale_node: =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = zoom_helpers.get_coordinates(e)

    @end_point=
      x: Math.round(coordinates.x)
      y: Math.round(coordinates.y)

    delta_x = Math.pow(@end_point.x - @start_point.x, 2)
    delta_y = Math.pow(@end_point.y - @start_point.y, 2)

    _radius = Math.max(20, Math.sqrt(delta_x + delta_y))

    @ghost_node.select('#ghost_node')
      .attr('r', Math.round(_radius))



  create_node: =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = zoom_helpers.get_coordinates(e)

    if @end_point?
      delta_x = Math.pow(@end_point.x - @start_point.x, 2)
      delta_y = Math.pow(@end_point.y - @start_point.y, 2)
      _radius = Math.max(20, Math.sqrt(delta_x + delta_y))
    else
      _radius = 50

    _length = Math.round(_radius*2)

    _node=
      x: @start_point.x
      y: @start_point.y
      nested: [ (new Path { height: _length, width: _length }).toJSON(), (new Text).toJSON() ]
    mediator.nodes.create _node, {wait: true}
    @reset()






