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
    super
    console.log 'Initializing CanvasView'
    #_.bindAll @, 'drag_group_start', 'drag_group_move', 'drag_group_end'

    #@subscribeEvent 'node_created', @draw
    #@subscribeEvent 'node_removed', @draw
    @subscribeEvent 'drag_group_end', @refresh
    
    $(window).on 'resize', @refresh
    
    @model.synced =>
      unless @rendered
        @render()
        @rendered = yes

  # ----------------------------------
  # FORCE/CANVAS METHODS
  # ----------------------------------

  force = d3.layout.force()

  viewport=
    height: -> return window.innerHeight
    width: -> return window.innerWidth

  bounds=
    height: viewport.height()-40
    width: viewport.width()
    x: [0, viewport.width()]
    y: [0, viewport.height()-40]

  force.on 'tick', ->
    #console.log mediator.vis.selectAll('g.nodeGroup')
    #.attr('transform', (d) -> 'translate('+ d.get('x') + ',' + d.get('y') + ')')
    
    bounds.x = d3.extent(force.nodes(), (d) -> return d.attributes.x )
    bounds.y = d3.extent(force.nodes(), (d) -> return d.attributes.y )
    bounds.height = Math.max((window.innerHeight-40), (bounds.y[1]+100))
    bounds.width = Math.max(window.innerWidth, (bounds.x[1]+100))


  # ----------------------------------
  # NODE GROUP METHODS
  # ----------------------------------

  drag_group_start: (d, i) ->
    console.log 'drag_group_start: (d, i) ->'
    mediator.selected_node = d
    mediator.publish 'clear_active_nodes'
    d3.select(@).classed 'moving', true
    d3.select(@).classed 'active', true
    force.stop()

  drag_group_move: (d, i) ->
    console.log 'drag_group_move: (d, i) ->'
    mediator.selected_node = null
    d3.select(@).classed 'active', false
    d3.select(@).attr('transform', 'translate('+ d3.event.x + ',' + d3.event.y + ')')
    force.tick()
  
  drag_group_end: (d, i) ->
    console.log 'drag_group_end: (d, i) ->'
    d3.select(@).classed 'moving', false
    force.resume()


  # ----------------------------------
  # DRAW CANVAS ELEMENTS
  # ----------------------------------

  draw: ->
    console.log 'draw: ->'
    
    drag_group = d3.behavior.drag()
      .on('dragstart', @drag_group_start)
      .on('drag', @drag_group_move)
      .on('dragend', @drag_group_end)
    
    mediator.node = mediator.vis
      .selectAll('g.nodeGroup')
      .data(mediator.nodes.models)
    
    #console.log 'Building ' + mediator.node[0].length + ' nodes:'
    #console.log mediator.node
    
    mediator.node.enter()
        .append('svg:g')
        .attr('class', 'nodeGroup')
        .attr('transform', (d)-> 'translate('+d.get('x')+','+d.get('y')+')')
        .call(drag_group)
        .each((d,i)-> d.view = new NodeView({model: d, el: @}))
        .transition()
          .ease Math.sqrt
        
    mediator.node.exit().remove()    
    
    d3.event.preventDefault() if d3.event
    force.start()


  # ----------------------------------
  # RENDER VIEW
  # ----------------------------------

  render: ->
    super
    console.log 'Rendering CanvasView [...]'
    
    mediator.outer = d3.select('#stage')
      .append('svg:svg')
      .attr('pointer-events', 'all');
    
    mediator.outer.append('svg:rect')
      .attr('id', 'canvas_background')
      .attr('fill', '#fff');
    
    mediator.vis = mediator.outer.append('svg:g')
      .attr('id', 'canvas_elements');
    
    force
      .charge(0)
      .gravity(0)
      .nodes(mediator.nodes.models)
      .size([bounds.width, bounds.height])
      .start()
    
    @subscribeEvent 'node_created', @draw
    @draw()



  # ----------------------------------
  # REFRESH CANVAS
  # ----------------------------------

  refresh: ->
    force.tick()
    console.log '⟲ Refreshing canvas { ' +
      'bounds.x: [' + bounds.x + '],' +
      'bounds.y: [' + bounds.y + '] ' + 
      'bounds.width: ' + bounds.width + ', ' +
      'bounds.height: ' + bounds.height + ' }'
    
    $('#canvas, #stage, #stage svg, #stage svg rect')
      .attr('height', bounds.height)
      .attr('width', bounds.width);    
    force
      .size([bounds.width, bounds.height])
      .start()
