mediator = require 'mediator'
View = require 'views/base/view'
template = require 'views/templates/canvas'

Node = require 'models/node'
NodeView = require 'views/node-view'

module.exports = class CanvasView extends View
  el: '#canvas'
  template: template
  regions:
    '#stage': 'stage'

  initialize: ->
    console.log 'Initializing CanvasView'
    super
    _.bindAll this, 'drag_group_end'
    _.bindAll this, 'd3_refs'
    
    $(window).on 'resize', @refresh_canvas
    @subscribeEvent 'node_created', @draw
    
    @model.synced =>
      unless @rendered
        @render()
        @rendered = yes

  force  = d3.layout.force()
  #outer = undefined
  d3_refs: ->
    outer: mediator.outer
    vis: 'vis'

  vis: -> 
    return 'test'
  #nodes = undefined
  #node  = undefined

  viewport=
    height: window.innerHeight
    width: window.innerWidth

  bounds=
    height: viewport.height-40
    width: viewport.width
    x: [0, viewport.width]
    y: [0, viewport.height-40]


  # ----------------------------------
  # NODE GROUP
  # ----------------------------------

  drag_group = d3.behavior.drag()
    .on('dragstart', @drag_group_start)
    .on('drag', @drag_group_move)
    .on('dragend', @drag_group_end)

  drag_group_start: (d, i) ->
    console.log 'starting drag'
    force.stop()

  drag_group_move: (d, i) ->
    d3.select(@).attr('transform', 'translate('+ d3.event.x + ',' + d3.event.y + ')')
    force.tick()
  
  drag_group_end: (d, i) ->
    @publishEvent 'node_group_dragged', {node: mediator.nodes[i], x: d3.event.sourceEvent.x, y: d3.event.sourceEvent.y}
    @refresh_canvas
    force.tick()
    force.resume()


  # ----------------------------------
  # RENDER CANVAS VIEW
  # ----------------------------------

  render: ->
    super
    console.log 'Rendering CanvasView [...]'
    
    mediator.outer = d3.select("#stage")
      .append('svg:svg')
      .attr('pointer-events', 'all');
    
    mediator.outer.append("svg:rect")
      .attr('id', 'canvas_background')
      .attr('fill', '#fff');
    
    mediator.vis = mediator.outer.append('svg:g')
      .attr('id', 'canvas_elements');
    
    force
      .charge(0)
      .gravity(0)
      .nodes(@model.nodes.models)
      .size([bounds.width, bounds.height])
      .start()
    
    mediator.nodes = force.nodes()
    mediator.node = mediator.vis.selectAll(".node")


  # ----------------------------------
  # DRAW CANVAS ELEMENTS
  # ----------------------------------

  draw: ->
    console.log 'Drawing!'
    drag_group = d3.behavior.drag()
      .on('dragstart', @drag_group_start)
      .on('drag', @drag_group_move)
      .on('dragend', @drag_group_end)
    
    mediator.node = mediator.node.data(mediator.nodes)
    mediator.node.enter()
        .append('svg:g')
        .attr('class', 'nodeGroup')
        .attr('transform', (d) -> 'translate('+ d.attributes.x + ',' + d.attributes.y + ')')
        .call(drag_group)
        .each((d,i)-> new NodeView({model: d, el: @}))
        .transition()
          .ease Math.sqrt
    mediator.node.exit().remove()
    d3.event.preventDefault() if d3.event
    force.start()

  force.on "tick", ->
    mediator.vis.selectAll("g.nodeGroup")
      #.attr('transform', (d) -> 'translate('+ d.attributes.x + ',' + d.attributes.y + ')')
    bounds.x = d3.extent(force.nodes(), (d) -> return d.attributes.x )
    bounds.y = d3.extent(force.nodes(), (d) -> return d.attributes.y )
    bounds.height = Math.max((window.innerHeight-40), (bounds.y[1]+100))
    bounds.width = Math.max(window.innerWidth, (bounds.x[1]+100))

  refresh_canvas: ->
    console.log '⟲ Refreshing canvas'
    console.log 'bounds.x: ' + bounds.x
    console.log 'bounds.y: ' + bounds.y
    console.log 'bounds.height: ' + bounds.height
    console.log 'bounds.width: ' + bounds.width
    
    $("#canvas, #stage, #stage svg, #stage svg rect")
      .attr("height", bounds.height)
      .attr("width", bounds.width);    
    force
      .size([bounds.width, bounds.height])
      .start()
