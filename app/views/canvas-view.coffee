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
  get_force: -> return force

  force.on 'tick', ->
    
    mediator.node
      .attr('transform', (d)-> return 'translate('+ d.x + ',' + d.y + ')')
    
    mediator.link.select('path')
      .attr('d', (d)->
        _target = _.where(force.nodes(), {id: d.target.id})[0]
        _source = _.where(force.nodes(), {id: d.source.id})[0]
        lx1 = _source.x - 5
        ly1 = _source.y - 5
        lx2 = _target.x - 5
        ly2 = _target.y - 5
        return '' +
          'M' + 
          _source.x + ',' + _source.y + ' ' +
          'L' +
          lx1 + ',' + ly1 + ' ' +
          'L' +
          lx2 + ',' + ly2 + ' ' +
          'L' +
          _target.x + ',' + _target.y
      )

  # ----------------------------------
  # NODE GROUP METHODS
  # ----------------------------------

  drag_group_start: (d, i) ->
    console.log 'drag_group_start'
    mediator.selected_node = d
    mediator.publish 'clear_active_nodes'
    #d.view.activate()
    #d3.select(@).classed 'moving', true
    d3.select(@).classed 'active', true
    #force.stop()

  drag_group_move: (d, i) ->
    console.log 'drag_group_move'
    mediator.selected_node = null
    d.x = d3.event.x
    d.y = d3.event.y
    d.px = d.x
    d.py = d.y
    #d.view.dectivate()
    d3.select(@).classed 'active', false
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ')')
    #force.tick()
  
  drag_group_end: (d, i) ->
    console.log 'drag_group_end'
    #d3.select(@).classed 'moving', false
    #force.resume()
    #force.start()
    


  # ----------------------------------
  # DRAW CANVAS ELEMENTS
  # ----------------------------------

  draw: ->
    console.log 'draw: ->'
    # DATA ---------------------

    force.nodes(_.map(
      mediator.nodes.models, (d,i)-> 
        return { id: d.get('_id'), x: d.get('x'), y: d.get('y'), model: d, view: d.view?, weight: 0 }
    ))

    force.links(_.map(
      mediator.links.models, (d)-> 
        console.log d
        data = { source: null, target: null, model: d, view: d.view? }
        data.source = _.where(force.nodes(), {id: d.get('source')})[0]
        data.target = _.where(force.nodes(), {id: d.get('target')})[0]
        return data
    ))


    # NODE ---------------------

    drag_node_group = d3.behavior.drag()
      .on('dragstart', @drag_group_start)
      .on('drag', @drag_group_move)
      .on('dragend', @drag_group_end)
    
    mediator.node = mediator.vis
      .selectAll('g.nodeGroup')
      .data(force.nodes())

    mediator.node
      .enter()
      .append('svg:g')
      .attr('class', 'nodeGroup')
      .call(drag_node_group)
      .transition()
        .ease Math.sqrt

    mediator.node
      .each((d,i)-> d.view = new NodeView({model: d.model, el: @}))

    mediator.node
      .exit()
      .remove()

    # LINK ---------------------

    mediator.link = mediator.vis
      .selectAll('g.linkGroup')
      .data(force.links())

    mediator.link
      .enter()
      .insert('svg:g', 'g.nodeGroup')
      .attr('class', 'linkGroup')
      .transition()
        .ease Math.sqrt

    mediator.link
      .each((d,i)-> d.view = new LinkView({model: d.model, el: @}))

    mediator.link
      .exit()
      .remove()
    

    # DONE ---------------------

    #d3.event.preventDefault() if d3.event
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
      #.linkDistance(150)
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
    bounds.x = d3.extent(force.nodes(), (d) -> return d.x ) if force.nodes().length > 0
    bounds.y = d3.extent(force.nodes(), (d) -> return d.y ) if force.nodes().length > 0
    bounds.height = Math.max((window.innerHeight-40), (bounds.y[1]+100))
    bounds.width = Math.max(window.innerWidth, (bounds.x[1]+100))
    #console.log '⟲ Refreshed Bounds:\n' + JSON.stringify(bounds, null, 4)
    
    $('#canvas, #stage, #stage svg, #stage svg rect')
      .attr('height', bounds.height)
      .attr('width', bounds.width);    
    force
      .size([bounds.width, bounds.height])
      .start()
