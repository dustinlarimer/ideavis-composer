mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class LinkView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super
    
    @subscribeEvent 'deactivate_detail', @deactivate
    @subscribeEvent 'clear_active', @clear
    
    @source = data.source
    @target = data.target    
    @baseline = d3.select(@el)
      .append('svg:path')
        .attr('class', 'baseline')

  render: ->
    super
    @build_baseline()
    console.log '[LinkView Rendered]'

  remove: ->
    @deactivate()
    console.log '[LinkView Removed]'
    super

  activate: ->
    console.log 'Link activated'
    d3.select(@el).classed('active', true)
    @build_points()

  deactivate: ->
    console.log '[LinkView Deactivated]'
    @controls?.remove()
    @filter?.remove()
    
    d3.select(@el).select('path.tickline')
      .call(d3.behavior.drag()
        .on('dragend', null))
      .remove()
    
    @baseline.attr('visibility', 'visible')
    @endpoints?.call(d3.behavior.drag()
      .on('dragstart', null)
      .on('drag', null)
      .on('dragend', null)).remove()
    @midpoints?.call(d3.behavior.drag()
      .on('dragend', null)).remove()
    #@clear()
    @render()

  clear: ->
    d3.select(@el).classed 'active', false
    @deactivate()


  # ----------------------------------
  # BUILD Baseline
  # ----------------------------------
  build_baseline: =>
    @build_markers()
    @baseline
      .attr('stroke', 'pink')
      .attr('stroke-dasharray', 'none')
      .attr('stroke-linecap', 'round')
      .attr('stroke-linejoin', 'round')
      .attr('stroke-opacity', .67)
      .attr('stroke-width', (d)-> d.model.get('stroke_width'))
      .attr('fill', 'none')
      .attr('marker-end', (d)-> return 'url(#' + 'link_' + d.id + '_marker_end)')


  # ----------------------------------
  # BUILD Markers
  # ----------------------------------
  build_markers: =>
    #console.log @model.get('marker_end')
    marker_end = d3.select('defs')
      .append('svg:marker')
        .attr('id', 'link_' + @model.id + '_marker_end')

    marker_end
        .attr('markerUnits', 'strokeWidth')
        .attr('orient', 'auto')
        .attr('refX', 0)
        .attr('refY', 0)

    #marker_end
    #    .attr('viewBox', '0 -5 10 10')
    #    .attr('markerHeight', 3)
    #    .attr('markerWidth', 4)
    #    .append('svg:path')
    #      .attr('d', 'M 0,0 m 0,-5 L 10,0 L 0,5 z')
    #      .attr('fill', '#333333')

    #'reverse'
    sw = @model.get('stroke_width')
    rev_w = 2 * sw
    rev_min_x = -2 * sw
    rev_min_y = -1 * sw/2
    rev_max_y = sw/2
    rev_v = '' + rev_min_x + ' ' + rev_min_y + ' ' + rev_w + ' ' + sw
    rev_d = 'M 0,0 m 0,' + rev_min_y + ' L ' + rev_min_x + ',0 L 0,' + rev_max_y + ' z'
    
    rev_width_px = 30 # 'user says 30px'
    rev_scale = rev_width_px / sw
    
    marker_end
        .attr('viewBox', rev_v)
        .attr('markerHeight', 1*rev_scale)
        .attr('markerWidth', 2*rev_scale)
        .append('svg:path')
          .attr('d', rev_d)
          #.attr('d', 'M 0,0 m 0,-10 L -20,0 L 0,10 z')
          .attr('fill', '#3498DB')
          .attr('opacity', .67)



  # ----------------------------------
  # BUILD Points
  # ----------------------------------
  build_points: =>
    console.log 'building points'
    
    mediator.outer.selectAll('g#link_controls').remove()
    @controls = mediator.outer
      .append('svg:g')
        .attr('id', 'link_controls')

    mediator.defs.selectAll('filter#link_point_drop_shadow').remove()
    @filter = mediator.defs.append('svg:filter')
      .attr('id', 'link_point_drop_shadow')
      .attr('x', '-25%')
      .attr('y', '-15%')
      .attr('height', '150%')
      .attr('width', '150%')

    @filter.append('svg:feGaussianBlur')
      .attr('in', 'SourceAlpha')
      .attr('stdDeviation', 1)

    @filter.append('svg:feOffset')
      .attr('dx', 0)
      .attr('dy', 1)

    @filter.append('svg:feComponentTransfer')
      .append('feFuncA')
        .attr('type', 'linear')
        .attr('slope', '0.35')

    feMerge = @filter.append('feMerge')
    feMerge.append('svg:feMergeNode')
    feMerge.append('svg:feMergeNode')
      .attr('in', 'SourceGraphic')

    endpoint_data = [
      { x: @source.x + @model.get('endpoints')[0][0], y: @source.y + @model.get('endpoints')[0][1] },
      { x: @target.x + @model.get('endpoints')[1][0], y: @target.y + @model.get('endpoints')[1][1] }
    ]
    @controls.selectAll('circle.endpoint').remove()
    @endpoints = @controls.selectAll('circle.endpoint')
      .data(endpoint_data)
      .enter()
      .append('svg:circle')
        .attr('class', 'point')
        .style('filter', 'url(#link_point_drop_shadow)')
        .attr('cx', (d)-> return d.x)
        .attr('cy', (d)-> return d.y)
        .attr('r', 10)
        .attr('fill', '#fff')
        .attr('cursor', 'move')
        .call(d3.behavior.drag()
          .on('dragstart', @drag_endpoint_start)
          .on('drag', @drag_endpoint_move)
          .on('dragend', @drag_endpoint_end))

    midpoint_data = []
    _.each(@model.get('midpoints'), (d,i)=>
      midpoint_data.push { x: @source.x + d[0], y: @source.y + d[1] }
    )
    @controls.selectAll('circle.midpoint').remove()
    @midpoints = @controls.selectAll('circle.midpoint')
      .data(midpoint_data)
      .enter()
      .append('svg:circle')
        .attr('class', 'point')
        .style('filter', 'url(#link_point_drop_shadow)')
        .attr('cx', (d)-> return d.x)
        .attr('cy', (d)-> return d.y)
        .attr('r', 5)
        .attr('fill', '#757575')
        .attr('stroke', '#fff')
        .attr('stroke-width', 2)
        .attr('cursor', 'move')
        .call(d3.behavior.drag()
          .on('dragstart', @drag_midpoint_start)
          .on('drag', @drag_midpoint_move)
          .on('dragend', @drag_midpoint_end))

    @baseline.attr('visibility', 'hidden')
    d3.select(@el).select('path.tickline').remove()
    tickline = d3.select(@el)
      .append('svg:path')
        .attr('class', 'tickline')
        .attr('stroke', => return @baseline.attr('stroke'))
        .attr('stroke-dasharray', => return @baseline.attr('stroke-dasharray'))
        .attr('stroke-linecap', => return @baseline.attr('stroke-linecap')) 
        .attr('stroke-linejoin', => return @baseline.attr('stroke-linejoin'))
        .attr('stroke-opacity', => return @baseline.attr('stroke-opacity'))
        .attr('stroke-width', => return @baseline.attr('stroke-width'))
        .attr('fill', 'none')
        .attr('marker-end', => return @baseline.attr('marker-end'))
        .attr('d', => return @baseline.attr('d'))
        .call(d3.behavior.drag()
          .on('dragend', @create_midpoint))


  # ----------------------------------
  # Endpoint Methods
  # ----------------------------------

  drag_endpoint_start: (d,i) ->
    #console.log 'Dragging: ' + i

  drag_endpoint_move: (d,i) ->
    d.x = d3.event.x
    d.y = d3.event.y
    d3.select(@)
      .attr('cx', (d)-> return d.x)
      .attr('cy', (d)-> return d.y)

  drag_endpoint_end: (d,i) =>
    if i is 0
      @model.save endpoints: [ [(d.x-@source.x),(d.y-@source.y)], @model.get('endpoints')[1] ]
      console.log 'Updated Source endpoint'
    else
      @model.save endpoints: [ @model.get('endpoints')[0], [(d.x-@target.x),(d.y-@target.y)] ]
      console.log 'Updated Target endpoint'
    mediator.publish 'refresh_canvas'


  # ----------------------------------
  # Midpoint Methods
  # ----------------------------------

  create_midpoint: (d,i) =>
    _all = d.model.get('midpoints')
    _new = [[(d3.event.sourceEvent.offsetX - @source.x),(d3.event.sourceEvent.offsetY - @source.y)]]
    console.log _new
    @model.save midpoints: _.union(_all, _new)
    @build_points()
    mediator.publish 'refresh_canvas'

  drag_midpoint_start: (d,i) =>
    #console.log 'midpoint:dragstart'

  drag_midpoint_move: (d,i) ->
    d.x = d3.event.x
    d.y = d3.event.y
    d3.select(@)
      .attr('cx', (d)-> return d.x)
      .attr('cy', (d)-> return d.y)

  drag_midpoint_end: (d,i) =>
    _midpoints = @model.get('midpoints')
    _midpoints[i][0] = d.x-@source.x
    _midpoints[i][1] = d.y-@source.y
    @model.save midpoints: _midpoints
    #console.log 'midpoint:dragend'
    mediator.publish 'refresh_canvas'



