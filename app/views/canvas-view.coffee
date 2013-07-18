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
      mediator.nodes.synced =>
        mediator.links.synced =>
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
    height: viewport.height()-50
    width: viewport.width()
    x: [0, viewport.width()]
    y: [0, viewport.height()-50]


  x = d3.scale.linear()
    .domain([0, bounds.width])
    .range([0, bounds.width])

  y = d3.scale.linear()
    .domain([0, bounds.height])
    .range([0, bounds.height])

  xAxis = d3.svg.axis()
    .scale(x)
    .orient('top')
    .tickPadding(-20)
    .ticks(20)
    .tickSize(-10,-5,0)
    .tickSubdivide(5)

  yAxis = d3.svg.axis()
    .scale(y)
    .orient('left')
    .tickPadding(-12)
    .ticks(10)
    .tickSize(-10,-5,0)
    .tickSubdivide(5)


  force = d3.layout.force()
  force.on 'tick', ->
    
    if mediator.node?
      mediator.node
        #.transition()
        #.ease('linear')
        .attr('opacity', (d)-> d.opacity)
        .attr('transform', (d)->
          return 'translate('+ d.x + ',' + d.y + ') rotate(' + d.rotate + ')'
        )

    if mediator.link?
      mediator.link
        .attr('opacity', (d)-> d.opacity)
        .selectAll('path.baseline, path.tickline')
        #.transition()
        #.ease('linear')
        #.duration(100)
        .attr('d', (d)->
          _target = _.findWhere(force.nodes(), {id: d.get('target')})
          _source = _.findWhere(force.nodes(), {id: d.get('source')})
          _interpolation = d.get('interpolation')
          if _target? and _source?
            _def = mediator.defs.select('path#link_' + d.id + '_path') #.transition().ease('linear').duration(100)
            _endpoints = d.get('endpoints')
            _midpoints = d.get('midpoints')
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
            _def.attr('d', line)
            return line
          else
            return 'M 0,0'
        )
      mediator.link
        .selectAll('.textpath')
          .attr('xlink:href', (d)-> '#link_' + d.id + '_path')



  # ----------------------------------
  # Initialize Artifacts
  # ----------------------------------

  init_artifacts: ->
    _.each(mediator.nodes.models, (node,i) => 
      force.nodes().push { id: node.id, x: node.get('x'), y: node.get('y'), opacity: node.get('opacity')/100, rotate: node.get('rotate'), scale: node.get('scale'), model: node }
    ) #if mediator.nodes?
    @subscribeEvent 'node_created', @add_node
    @subscribeEvent 'node_updated', @update_node
    @subscribeEvent 'node_removed', @remove_node
    @build_nodes()
    
    _.each(mediator.links.models, (link,i) => 
      _source = _.where(force.nodes(), {id: link.get('source')})[0]
      _target = _.where(force.nodes(), {id: link.get('target')})[0]
      force.links().push { id: link.id, source: _source, target: _target, opacity: link.get('stroke_opacity')/100, model: link }
    ) #if mediator.links?
    @subscribeEvent 'link_created', @add_link
    @subscribeEvent 'link_updated', @update_link
    @subscribeEvent 'link_removed', @remove_link
    @build_links()



  # ----------------------------------
  # NODES
  # ----------------------------------

  drag_node_start: (d, i) ->
    mediator.publish 'refresh_canvas'

  drag_node_move: (d, i) ->
    #console.log 'drag_node_move'
    d.rotate = d.model.get('rotate')
    d.x = d3.event.x
    d.y = d3.event.y
    d.px = d.x
    d.py = d.y
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ') rotate(' + d.rotate + ')')
  
  drag_node_end: (d, i) ->
    mediator.publish 'refresh_canvas'

  add_node: (node) ->
    force.nodes().push { id: node.id, x: node.get('x'), y: node.get('y'), opacity: node.get('opacity')/100, rotate: node.get('rotate'), model: node }
    @build_nodes()

  update_node: (node) ->
    _.each(force.nodes(), (d,i)->
      if d.id is node.id
        d.x = node.get('x')
        d.y = node.get('y') 
        d.opacity = node.get('opacity')/100
        d.rotate = node.get('rotate')
        #d.scale = node.get('scale') or 1
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
      .attr('opacity', (d)-> d.model.get('opacity')/100)
      .attr('transform', (d)->
        return 'translate('+ d.x + ',' + d.y + ') rotate(' + d.model.get('rotate') + ')'
      )
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
    force.links().push { id: link.id, source: _source, target: _target, opacity: link.get('stroke_opacity')/100, model: link }
    @build_links()

  update_link: (link) ->
    _.each(force.links(), (d,i)->
      if d.id is link.id
        d.opacity = link.get('stroke_opacity')/100
    )
    @refresh()

  remove_link: (link_id) ->
    _link = _.findWhere(force.links(), {id: link_id})
    _index = force.links().indexOf(_link)
    force.links().splice(_index,1)
    @refresh()

  build_links: ->
    #force.stop()
    mediator.link = mediator.vis
      .selectAll('g.linkGroup')
      .data(force.links())
    
    mediator.link
      .enter()
      .insert('svg:g', 'g.nodeGroup')
      .attr('class', 'linkGroup')
      .attr('pointer-events', 'visibleStroke')
      .attr('opacity', (d)-> d.model.get('stroke_opacity')/100)
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
      .attr('xmlns', 'http://www.w3.org/2000/svg')
      .attr('xmlns:xmlns:xlink', 'http://www.w3.org/1999/xlink')
      #.attr('xml:xml:space', 'preserve')
      .attr('pointer-events', 'all')
    
    mediator.defs = mediator.outer.append('svg:defs')
    
    mediator.stage = mediator.outer.append('svg:g')
      .attr('id', 'canvas_wrapper')
      .call(zoom)
    
    mediator.stage.append('svg:rect')
      .attr('id', 'canvas_background')
      .attr('fill', '#fff')
    mediator.stage.append('svg:g')
      .attr('class', 'x axis')
      .call(xAxis)
    mediator.stage.append('svg:g')
      .attr('class', 'y axis')
      .call(yAxis)
    mediator.stage.append('svg:rect')
      .attr('id', 'canvas_elements_background')
      .attr('fill', 'none')
    
    mediator.vis = mediator.stage.append('svg:g')
      .attr('id', 'canvas_elements')

    mediator.controls = mediator.stage.append('svg:g')
      .attr('id', 'canvas_controls')

    force
      .charge(0)
      .gravity(0)
      .linkStrength(0)
      .size([bounds.width, bounds.height])
    
    @subscribeEvent 'refresh_canvas', @refresh
    @init_artifacts()



  # ----------------------------------
  # REFRESH CANVAS
  # ----------------------------------

  refresh: =>
    detail_offset = ($('#detail').width()*1.3) or 0
    canvas_elements = $('#canvas_elements')[0].getBoundingClientRect()
    bounds.x = canvas_elements.width + detail_offset # width of DetailView
    bounds.y = Math.max(canvas_elements.bottom-50, canvas_elements.height) + 50
    bounds.height = window.innerHeight-50
    bounds.width = window.innerWidth-50
    #bounds.height = Math.max((window.innerHeight-50), bounds.y)
    #bounds.width = Math.max(window.innerWidth-50, bounds.x)
    #console.log '⟲ Refreshed Bounds:\n' + JSON.stringify(bounds, null, 4)
    
    $('svg, #canvas_background, #canvas_elements_background')
      .attr('height', bounds.height)
      .attr('width', bounds.width)
    
    force
      .size([bounds.width, bounds.height])
      .start()

    #mediator.stage.select('g.x').call(xAxis)
    #mediator.stage.select('g.y').call(yAxis)


  # ----------------------------------
  # ZOOM CANVAS
  # ----------------------------------

  zoom = d3.behavior.zoom()
    .x(x)
    .y(y)
    .scaleExtent([1, 10])
    .on('zoom', ->
      if mediator.zoom
        mediator.offset = [d3.event.translate, d3.event.scale]
        #console.log mediator.offset[0]
        d3.select('#canvas_elements')
          .attr('transform', 'translate(' + d3.event.translate + ') scale(' + d3.event.scale + ')')
        d3.select('#canvas_controls')
          .attr('transform', 'translate(' + d3.event.translate + ') scale(' + d3.event.scale + ')')
        mediator.stage?.select('.x.axis').call(xAxis)
        mediator.stage?.select('.y.axis').call(yAxis)
        d3.selectAll('g.axis text').transition().ease('linear').style('opacity', 1)
        setTimeout =>
          d3.selectAll('g.axis text').transition().ease('linear').style('opacity', 0)
        , 4000
    )

