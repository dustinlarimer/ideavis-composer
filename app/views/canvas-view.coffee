mediator = require 'mediator'
View = require 'views/base/view'
template = require 'views/templates/canvas'

Node = require 'models/node'
NodeView = require 'views/node-view'

Link = require 'models/link'
LinkView = require 'views/link-view'

module.exports = class CanvasView extends View
  el: '#canvas'
  template: template
  regions:
    '#stage': 'stage'

  initialize: ->
    super
    console.log 'Initializing CanvasView'
    $(window).on 'resize', @refresh
    
    @model.synced =>
      unless @rendered
        @render()
        @rendered = yes



  # ----------------------------------
  # FORCE/CANVAS METHODS
  # ----------------------------------
 
  viewport=
    height: -> return window.innerHeight
    width: -> return window.innerWidth

  bounds=
    height: viewport.height()-40
    width: viewport.width()
    x: [0, viewport.width()]
    y: [0, viewport.height()-40]

  force = d3.layout.force()
  force_nodes = []
  force_links = []
  
  lookup_nodes = []
  lookup_links = []

  force.on 'tick', ->
    #mediator.vis.selectAll('g.nodeGroup')
    mediator.node
      .attr('transform', (d)-> return 'translate('+ d.x + ',' + d.y + ')')
  
    mediator.link.select('path')
      .attr('d', (d)->
        #console.log lookup_nodes[d.target.id].x
        _target = lookup_nodes[d.target.id]
        _source = lookup_nodes[d.source.id]
        dx = _target.x
        dy = _target.y
        dr = Math.sqrt(dx * dx + dy * dy)
        return '' +
          'M' +
          _source.x + ',' +
          _source.y + 
          'A' +
          dr + ',' + dr + ' 0 0,1 ' +
          _target.x + ',' +
          _target.y
      )

  # ----------------------------------
  # NODE GROUP METHODS
  # ----------------------------------

  drag_group_start: (d, i) ->
    console.log 'drag_group_start'
    mediator.selected_node = d
    mediator.publish 'clear_active_nodes'
    d3.select(@).classed 'moving', true
    d3.select(@).classed 'active', true
    #force.stop()

  drag_group_move: (d, i) ->
    console.log 'drag_group_move'
    mediator.selected_node = null
    d.x = d3.event.x
    d.y = d3.event.y
    d.px = d.x
    d.py = d.y
    d3.select(@).classed 'active', false
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ')')
    lookup_nodes[d.id] = d
    #force.tick()
  
  drag_group_end: (d, i) ->
    console.log 'drag_group_end'
    d3.select(@).classed 'moving', false
    #force.resume()
    #force.start()



  # ----------------------------------
  # DRAW CANVAS ELEMENTS
  # ----------------------------------

  draw: ->
    console.log 'draw: ->'

    drag_node_group = d3.behavior.drag()
      .on('dragstart', @drag_group_start)
      .on('drag', @drag_group_move)
      .on('dragend', @drag_group_end)

    # PREP---------------------
    force_nodes = _.map(
      mediator.nodes.models, (d,i)-> 
        return { id: d.get('_id'), x: d.get('x'), y: d.get('y'), model: d, view: null, weight: 0 }
    )
    force.nodes(force_nodes)

    force_links = _.map(
      mediator.links.models, (d)-> 
        data = { source: null, target: null, model: d, view: null }
        data.source = lookup_nodes[d.get('source').get('_id')]
        data.target = lookup_nodes[d.get('target').get('_id')]
        d = data
        return d
    )
    force.links(force_links)
    #console.log force.links()

    # NODES---------------------
    mediator.node = mediator.vis
      .selectAll('g.nodeGroup')
      .data(force_nodes)
    mediator.node.enter()
      .append('svg:g')
      .attr('class', 'nodeGroup')
      .call(drag_node_group)
      .each((d)-> lookup_nodes[d.id] = d)
      .each((d,i)-> d.view = new NodeView({model: d.model, el: @}))
      .transition()
        .ease Math.sqrt
    mediator.node.exit().remove()

    # LINKS---------------------
    mediator.link = mediator.vis
      .selectAll('g.linkGroup')
      .data(force_links)
    #console.log 'Building ' + mediator.link[0].length + ' links:'
    #console.log mediator.link[0]
    mediator.link
      .enter()
        .insert('svg:g', 'g.nodeGroup')
        #.append('svg:g')
        .attr('class', 'linkGroup')
        .append('svg:path')
        #.each((d,i)-> d.view = new LinkView({model: d.model, el: @}))
        .transition()
          .ease Math.sqrt
    mediator.link.exit().remove()
    
    # FIN!---------------------
    d3.event.preventDefault() if d3.event
    force.start()
    @refresh()



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
      .links(mediator.links.models)
      .linkStrength(0)
      .size([bounds.width, bounds.height])
      .start()
    
    @subscribeEvent 'node_created', @draw
    @subscribeEvent 'node_updated', @refresh
    @subscribeEvent 'node_removed', @refresh

    @subscribeEvent 'link_created', @draw
    @subscribeEvent 'link_updated', @refresh
    @subscribeEvent 'link_removed', @refresh
    
    @draw()



  # ----------------------------------
  # REFRESH CANVAS
  # ----------------------------------

  refresh: ->
    bounds.x = d3.extent(force.nodes(), (d) -> return d.x )
    bounds.y = d3.extent(force.nodes(), (d) -> return d.y )
    bounds.height = Math.max((window.innerHeight-40), (bounds.y[1]+100))
    bounds.width = Math.max(window.innerWidth, (bounds.x[1]+100))
    #console.log '⟲ Refreshed Bounds:\n' + JSON.stringify(bounds, null, 4)
    
    $('#canvas, #stage, #stage svg, #stage svg rect')
      .attr('height', bounds.height)
      .attr('width', bounds.width);    
    force
      .size([bounds.width, bounds.height])
      .start()
