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
      .selectAll('path.baseline, path.tickline')
      .transition()
      .ease(Math.sqrt)
      .attr('d', (d)->
        _target = _.findWhere(force.nodes(), {id: d.target.id})
        _source = _.findWhere(force.nodes(), {id: d.source.id})
        _interpolation = d.model.get('interpolation')
        if _target? and _source?
          _endpoints = d.model.get('endpoints')
          _midpoints = d.model.get('midpoints')
          data = []
          data.push { x: _source.x + _endpoints[0][0], y: _source.y + _endpoints[0][1] }
          _.each(_midpoints, (m,i)->
            data.push { x: _midpoints[i][0], y: _midpoints[i][1] }
          )
          data.push { x: _target.x + _endpoints[1][0], y: _target.y + _endpoints[1][1] }
          line = d3.svg.line()
                   .x((d)-> return d.x)
                   .y((d)-> return d.y)
                   .interpolate(_interpolation)(data)
          if _interpolation is 'basis' and _midpoints.length > 0
            _curves = line.split('C')
            _last = _curves.pop()
            _line = _curves.join('C')
            data = _last.split(',')
            _line += 'L' + data.slice(data.length - 2).join(',')
            return _line
          else
            return line
        else
          return 'M 0,0'
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
    mediator.publish 'refresh_canvas'
    mediator.selected_node = d
    mediator.publish 'clear_active_nodes'
    #force.start()

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
    #force.tick()
  
  drag_node_end: (d, i) ->
    mediator.publish 'refresh_canvas'
    #force.start()

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
      .attr('pointer-events', 'visibleStroke')
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
    
    mediator.defs = mediator.outer.append('svg:defs')
    
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
    canvas_elements = $('#canvas_elements')[0].getBoundingClientRect()
    bounds.x = canvas_elements.width + 320 # width of DetailView
    bounds.y = canvas_elements.height + 50
    bounds.height = Math.max((window.innerHeight-50), bounds.y)
    bounds.width = Math.max(window.innerWidth-50, bounds.x)
    #console.log '⟲ Refreshed Bounds:\n' + JSON.stringify(bounds, null, 4)
    
    $('#canvas')
      .css('height', bounds.height+50)
      .css('width', bounds.width+50)
    $('#stage')
      .css('height', bounds.height + 50)
      .css('width', bounds.width)
    $('#stage svg, #stage svg #canvas_background')
      .attr('height', bounds.height)
      .attr('width', bounds.width)
    
    force
      .size([bounds.width, bounds.height])
      .start()

