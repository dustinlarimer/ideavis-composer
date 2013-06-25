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

  force.on 'tick', ->
    
    mediator.node
      .transition()
      .ease(Math.sqrt)
      .attr('transform', (d)->
        return 'translate('+ d.x + ',' + d.y + ') scale(' + d.scale + ') rotate(' + d.rotate + ')'
      ) if mediator.node?

    mediator.link
      .select('path.baseline')
      .transition()
      .ease(Math.sqrt)
      .attr('d', (d)->
        _target = _.findWhere(force.nodes(), {id: d.target.id})
        _source = _.findWhere(force.nodes(), {id: d.source.id})
        if _target? and _source?
          data = [ { x: _source.x, y: _source.y }, { x: _target.x, y: _target.y } ]
          line = d3.svg.line()
                   .x((d)-> return d.x)
                   .y((d)-> return d.y)
                   .tension(0)
                   .interpolate('cardinal-closed')
          return line(data)
      ) if mediator.link?



  # ----------------------------------
  # Initialize Artifacts
  # ----------------------------------

  init_artifacts: ->
    _.each(mediator.nodes.models, (node,i) => 
      force.nodes().push { id: node.id, x: node.get('x'), y: node.get('y'), rotate: node.get('rotate'), scale: node.get('scale'), model: node }
    )
    @build_nodes()

    _.each(mediator.links.models, (link,i) => 
      _source = _.where(force.nodes(), {id: link.get('source')})[0]
      _target = _.where(force.nodes(), {id: link.get('target')})[0]
      force.links().push { id: link.id, source: _source, target: _target, model: link }
    )
    @build_links()



  # ----------------------------------
  # NODES
  # ----------------------------------

  drag_node_start: (d, i) ->
    console.log 'drag_node_start'
    mediator.selected_node = d
    mediator.publish 'clear_active_nodes'
    force.start()

  drag_node_move: (d, i) ->
    console.log 'drag_node_move'
    mediator.selected_node = null
    d.scale = d.model.get('scale') or 1
    d.rotate = d.model.get('rotate')
    d.x = d3.event.x
    d.y = d3.event.y
    d.px = d.x
    d.py = d.y
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ') scale(' + d.scale + ') rotate(' + d.rotate + ')')
    force.tick()
  
  drag_node_end: (d, i) ->
    console.log 'drag_node_end'
    force.start()

  add_node: (node) ->
    force.nodes().push { id: node.id, x: node.get('x'), y: node.get('y'), rotate: node.get('rotate'), scale: node.get('scale'), model: node }
    @build_nodes()

  update_node: (node) ->
    _.each(force.nodes(), (d,i)->
      if d.id is node.id
        d.x = node.get('x')
        d.y = node.get('y') 
        d.rotate = node.get('rotate')
        d.scale = node.get('scale') or 1
        d.px = d.x
        d.py = d.y
    )
    @refresh()

  remove_node: (node_id) ->
    _node = _.findWhere(force.nodes(), {id: node_id})
    _index = force.nodes().indexOf(_node)
    force.nodes().splice(_index,1)
    @refresh()

  build_nodes: ->
    console.log 'building'
    
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
    
    @refresh()



  # ----------------------------------
  # LINKS
  # ----------------------------------

  add_link: (link) ->
    _source = _.where(force.nodes(), {id: link.get('source')})[0]
    _target = _.where(force.nodes(), {id: link.get('target')})[0]
    force.links().push { id: link.id, source: _source, target: _target, model: link }
    @build_links()

  remove_link: (link_id) ->
    _link = _.findWhere(force.links(), {id: link_id})
    _index = force.links().indexOf(_link)
    force.links().splice(_index,1)
    @refresh()

  build_links: ->
    force.stop()
    mediator.link = mediator.vis
      .selectAll('g.linkGroup')
      .data(force.links())
    
    mediator.link
      .enter()
      .insert('svg:g', 'g.nodeGroup')
      .attr('class', 'linkGroup')
      .each((d,i)-> d.view = new LinkView({model: d.model, el: @, source: d.source, target: d.target}))
    
    mediator.link
      .exit()
      .remove()
    
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
    
    @subscribeEvent 'refresh_canvas', @refresh
    
    @subscribeEvent 'node_created', @add_node
    @subscribeEvent 'node_updated', @update_node
    @subscribeEvent 'node_removed', @remove_node

    @subscribeEvent 'link_created', @add_link
    @subscribeEvent 'link_removed', @remove_link
    
    @init_artifacts()



  # ----------------------------------
  # REFRESH CANVAS
  # ----------------------------------

  refresh: ->
    bounds.x = d3.extent(force.nodes(), (d) -> return d.x ) if force.nodes().length > 0
    bounds.y = d3.extent(force.nodes(), (d) -> return d.y ) if force.nodes().length > 0
    bounds.height = Math.max((window.innerHeight-50), (bounds.y[1]+100))
    bounds.width = Math.max(window.innerWidth-50, (bounds.x[1]+320))
    #console.log '⟲ Refreshed Bounds:\n' + JSON.stringify(bounds, null, 4)
    
    $('#canvas')
      .attr('height', bounds.height)
      .attr('width', bounds.width)
    $('#stage')
      .attr('height', bounds.height)
      .attr('width', bounds.width-50)
    $('#stage svg, #stage svg #canvas_background')
      .attr('height', bounds.height)
      .attr('width', bounds.width)
    
    force
      .size([bounds.width, bounds.height])
      .start()

