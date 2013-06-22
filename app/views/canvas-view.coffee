mediator = require 'mediator'
View = require 'views/base/view'
template = require 'views/templates/canvas'

NodeView = require 'views/node-view'
LinkView = require 'views/link-view'

module.exports = class CanvasView extends View
  el: '#canvas'
  template: template

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
      .transition()
      .ease(Math.sqrt)
      .attr('transform', (d)->
        return 'translate('+ d.x + ',' + d.y + ') scale(' + d.model.get('scale') + ') rotate(' + d.model.get('rotate') + ')'
      )

    mediator.link.select('path')
      .transition()
      .ease(Math.sqrt)
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

  drag_node_start: (d, i) ->
    console.log 'drag_node_start'
    mediator.selected_node = d
    mediator.publish 'clear_active_nodes'
    d3.select(@).classed 'active', true
    force.start()

  drag_node_move: (d, i) ->
    console.log 'drag_node_move'
    mediator.selected_node = null
    d.scale = d.model.get('scale')
    d.rotate = d.model.get('rotate')
    d.x = d3.event.x
    d.y = d3.event.y
    d.px = d.x
    d.py = d.y
    #d3.select(@).classed 'active', false
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ') scale(' + d.scale + ') rotate(' + d.rotate + ')')
    force.tick()
  
  drag_node_end: (d, i) ->
    console.log 'drag_node_end'
    force.start()



  # ----------------------------------
  # DRAW CANVAS ELEMENTS
  # ----------------------------------

  

  init_artifacts: ->
    force.nodes(_.map(
      mediator.nodes.models, (d,i)-> 
        return { id: d.get('_id'), x: d.get('x'), y: d.get('y'), model: d, view: d.view?, weight: 0 }
    ))
    force.links(_.map(
      mediator.links.models, (d)-> 
        #console.log d
        data = { source: null, target: null, model: d, view: d.view? }
        data.source = _.where(force.nodes(), {id: d.get('source')})[0]
        data.target = _.where(force.nodes(), {id: d.get('target')})[0]
        return data
    ))
    @draw()

  add_node: (node) ->
    console.log 'adding'
    console.log node
    force.nodes().push({ id: node.get('_id'), x: parseInt(node.get('x')), y: parseInt(node.get('7')), model: node, view: node.view?, weight: 0 })
    @draw()

  update_node: (node) ->
    _.each(force.nodes(), (d,i)->
      if d.id is node.id
        d.x = parseInt(d.model.get('x'))
        d.y = parseInt(d.model.get('y'))
        d.px = d.x
        d.py = d.y
    )


  remove_node: (node) ->
    _.map(force.nodes(), (d,i)-> 
      if d.model.id == node.id
        force.nodes().splice(i)
    )
    @refresh()

  add_link: (link) ->
    console.log 'adding'
    @draw()

  draw: ->

    # NODE ---------------------

    node_drag_events = d3.behavior.drag()
      .on('dragstart', @drag_node_start)
      .on('drag', @drag_node_move)
      .on('dragend', @drag_node_end)
    
    mediator.node = mediator.vis
      .selectAll('g.nodeGroup')
      .data(force.nodes())

    mediator.node
      .enter()
      .append('svg:g')
      .attr('class', 'nodeGroup')
      .attr('transform', (d)->
        return 'translate('+ d.x + ',' + d.y + ') scale(' + d.model.get('scale') + ') rotate(' + d.model.get('rotate') + ')')
      .each((d,i)-> d.view = new NodeView({model: d.model, el: @}))
      .call(node_drag_events)

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
      #.friction(1)
      #.linkDistance(150)
      .linkStrength(0)
      .size([bounds.width, bounds.height])
      #.start()
    
    @subscribeEvent 'node_created', @add_node
    @subscribeEvent 'node_updated', @update_node
    @subscribeEvent 'node_removed', @remove_node

    @subscribeEvent 'link_created', @add_link
    @subscribeEvent 'link_updated', @draw
    @subscribeEvent 'link_removed', @refresh
    
    @init_artifacts()



  # ----------------------------------
  # REFRESH CANVAS
  # ----------------------------------

  refresh: ->
    bounds.x = d3.extent(force.nodes(), (d) -> return d.x ) if force.nodes().length > 0
    bounds.y = d3.extent(force.nodes(), (d) -> return d.y ) if force.nodes().length > 0
    bounds.height = Math.max((window.innerHeight-40), (bounds.y[1]+100))
    bounds.width = Math.max(window.innerWidth, (bounds.x[1]+100))
    #console.log '⟲ Refreshed Bounds:\n' + JSON.stringify(bounds, null, 4)
    
    $('#canvas, #stage, #stage svg, #stage svg #canvas_background')
      .attr('height', bounds.height)
      .attr('width', bounds.width)
    
    force
      .size([bounds.width, bounds.height])
      .start()

  $ ->
    setInterval (->
      force.start()
    ), 7000

