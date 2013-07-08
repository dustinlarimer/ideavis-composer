mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class LinkView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

    @source = data.source
    @target = data.target
    
    @label = d3.select(@el).selectAll('text')
    @baseline = d3.select(@el).selectAll('path.baseline')
    @tickline = d3.select(@el).selectAll('path.tickline')    
    @textline = mediator.defs
      .append('svg:path')
        .attr('id', 'link_' + @model.id + '_path')
        .attr('class', 'textline')
    
    @marker_start = mediator.defs.selectAll('marker' + '#link_' + @model.id + '_marker_start')
    @marker_end = mediator.defs.selectAll('marker' + '#link_' + @model.id + '_marker_end')
    @selected_endpoint = null
    
    #@subscribeEvent 'deactivate_detail', @deactivate
    @subscribeEvent 'clear_active', @clear

    @listenTo @model, 'change', @build_baseline
    @listenTo @model.marker_start, 'change', @build_markers
    @listenTo @model.marker_end, 'change', @build_markers

  render: ->
    super
    @build_baseline()
    console.log '[LinkView Rendered]'

  remove: ->
    @baseline?.remove()
    @tickline?.remove()
    @textline?.remove()
    @label?.remove()
    @marker_start?.remove()
    @marker_end?.remove()
    @deactivate()
    console.log '[LinkView Removed]'
    super

  activate: ->
    key 'backspace', 'link', @keypress_delete
    key.setScope 'link'
    
    d3.select(@el).classed('active', true)
    @baseline.attr('visibility', 'hidden')
    @tickline
      .attr('visibility', 'visible')
      .call(d3.behavior.drag()
        .on('dragend', @create_midpoint))
    @build_points()

  deactivate: ->
    key.unbind 'backspace', 'link'
    
    @baseline.attr('visibility', 'visible')
    @tickline
      .attr('visibility', 'hidden')
      .call(d3.behavior.drag()
        .on('dragend', null))
    
    @endpoints?.call(d3.behavior.drag()
      .on('dragstart', null)
      .on('drag', null)
      .on('dragend', null)).remove()
    @midpoints?.call(d3.behavior.drag()
      .on('dragstart', null)
      .on('drag', null)
      .on('dragend', null)).remove()
    @controls?.remove()
    @filter?.remove()

  clear: ->
    d3.select(@el).classed 'active', false
    @deactivate()


  # ----------------------------------
  # KEYBOARD SHORTCUTS
  # ----------------------------------
  keypress_delete: =>
    console.log 'keypress_delete: =>'
    if mediator.selected_link and mediator.selected_link.model is @model
      if @selected_midpoint?
        @destroy_midpoint()
      else
        @model.destroy()
        @dispose()
    return false


  # ----------------------------------
  # BUILD Baseline
  # ----------------------------------
  build_baseline: =>
    @build_markers()
    
    @baseline = @baseline.data([@model])
    @baseline
      .enter()
      .append('svg:path')
      .attr('class', 'baseline')
        .attr('visibility', 'visible')
      .attr('shape-rendering', 'geometricPrecision')
      .attr('stroke', (d)-> d.get('stroke'))
      .attr('stroke-dasharray', (d)-> d.get('stroke_dasharray'))
      .attr('stroke-linecap', (d)-> d.get('stroke_linecap'))
      .attr('stroke-linejoin', (d)-> d.get('stroke_linecap'))
      .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
      .attr('stroke-width', (d)-> d.get('stroke_width'))
      .attr('fill', (d)-> d.get('fill'))
      #.attr('marker-start', (d)-> 'url(#' + 'link_' + d.id + '_marker_start)')
      #.attr('marker-end',   (d)-> 'url(#' + 'link_' + d.id + '_marker_end)')

    @baseline
      .attr('stroke', (d)-> d.get('stroke'))
      .attr('stroke-dasharray', (d)-> d.get('stroke_dasharray'))
      .attr('stroke-linecap', (d)-> d.get('stroke_linecap'))
      .attr('stroke-linejoin', (d)-> 
        _linecap = d.get('stroke_linecap')
        if _linecap is 'square' then return 'miter' else if _linecap is 'butt' then return 'bevel' else return _linecap
      )
      .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
      .attr('stroke-width', (d)-> d.get('stroke_width'))
      .attr('fill', (d)-> d.get('fill'))

    #d3.select(@el).select('path.tickline').remove()
    #tickline = d3.select(@el).selectAll('path.tickline').data([@model])

    @tickline = @tickline.data([@model])
    @tickline
      .enter()
      .append('svg:path')
        .attr('class', 'tickline')
        .attr('visibility', 'hidden')
        .attr('shape-rendering', 'geometricPrecision')
        .attr('stroke', (d)=> return @baseline.attr('stroke'))
        .attr('stroke-dasharray', (d)=> return @baseline.attr('stroke-dasharray'))
        .attr('stroke-linecap', (d)=> return @baseline.attr('stroke-linecap'))
        .attr('stroke-linejoin', (d)=> return @baseline.attr('stroke-linejoin'))
        .attr('stroke-opacity', (d)=> return @baseline.attr('stroke-opacity'))
        .attr('stroke-width', (d)=> return @baseline.attr('stroke-width'))
        .attr('fill', (d)=> return @baseline.attr('fill'))
        #.attr('marker-start', (d)-> 'url(#' + 'link_' + d.id + '_marker_start)')
        #.attr('marker-end',   (d)-> 'url(#' + 'link_' + d.id + '_marker_end)')

    @tickline
      .attr('stroke', (d)=> return @baseline.attr('stroke'))
      .attr('stroke-dasharray', (d)=> return @baseline.attr('stroke-dasharray'))
      .attr('stroke-linecap', (d)=> return @baseline.attr('stroke-linecap'))
      .attr('stroke-linejoin', (d)=> return @baseline.attr('stroke-linejoin'))
      .attr('stroke-opacity', (d)=> return @baseline.attr('stroke-opacity'))
      .attr('stroke-width', (d)=> return @baseline.attr('stroke-width'))
      .attr('fill', (d)=> return @baseline.attr('fill'))

    @label = @label.data([@model])
    @label
      .enter()
      .append('svg:text')
        .attr('fill', (d)=> d.get('label_fill'))
        .attr('fill-opacity', (d)=> d.get('label_fill_opacity')/100)
        .attr('font-size', (d)=> d.get('label_font_size'))
        .append('svg:textPath')
          .attr('class', 'textpath')
          .attr('xlink:href', (d)=> '#link_' + d.id + '_path')
          .attr('letter-spacing', (d)=> d.get('label_spacing'))
          .attr('startOffset', (d)=> d.get('label_offset_x'))
          .append('svg:tspan')
            .attr('class', 'tspan')
            .attr('dy', (d)=> -1 * d.get('label_offset_y'))
            .text((d)=> d.get('label_text'))

    @label
      .attr('fill', (d)=> d.get('label_fill'))
      .attr('fill-opacity', (d)=> d.get('label_fill_opacity')/100)
      .attr('font-size', (d)=> d.get('label_font_size'))
      .transition()
        .ease('linear')
        .selectAll('.textpath')
          .attr('letter-spacing', (d)=> d.get('label_spacing'))
          .attr('startOffset', (d)=> d.get('label_offset_x'))
          .selectAll('.tspan')
            .attr('dy', (d)=> -1 * d.get('label_offset_y'))
            .text((d)=> d.get('label_text'))

  # ----------------------------------
  # BUILD Markers
  # ----------------------------------
  build_markers: =>
    #console.log @model.get('marker_end')
    #unless @model.marker_start.get('type') is 'none'
    
    @marker_start = @marker_start.data([@model.marker_start])
    @marker_start
      .enter()
      .append('svg:marker')
        .attr('id', 'link_' + @model.id + '_marker_start')
        .attr('class', 'marker-start')
        .attr('markerUnits', 'strokeWidth')
        .attr('orient', 'auto')
        .attr('refY', 0)

    @marker_start
        .each((d,i)=> @generate_marker_path(d))
        .attr('refX', (d)=> return -1 * d.get('offset_x') / @model.get('stroke_width'))
        .attr('viewBox', (d)-> d.viewbox)
        .attr('markerHeight', (d)-> d.markerHeight)
        .attr('markerWidth', (d)-> d.markerWidth)
        .append('svg:path')
          .attr('d', (d)-> d.path)
          .attr('fill', (d)=> 
            if d.get('fill') is 'none'
              return @model.get('stroke')
            else
              return d.get('fill')
          )
          .attr('shape-rendering', 'geometricPrecision')
          .attr('fill-opacity', (d)-> return d.get('fill_opacity'))
          .attr('stroke', (d)-> return d.get('stroke'))
          .attr('stroke-opacity', (d)-> return d.get('stroke_opacity'))
          .attr('stroke-width', (d)-> return d.get('stroke'))


    @marker_end = @marker_end.data([@model.marker_end])
    @marker_end
      .enter()
      .append('svg:marker')
        .attr('id', 'link_' + @model.id + '_marker_end')
        .attr('class', 'marker-end')
        .attr('markerUnits', 'strokeWidth')
        .attr('orient', 'auto')
        .attr('refY', 0)
    
    @marker_end
        .each((d,i)=> @generate_marker_path(d))
        .attr('refX', (d)=> return d.get('offset_x') / @model.get('stroke_width'))
        .attr('viewBox', (d)-> d.viewbox)
        .attr('markerHeight', (d)-> d.markerHeight)
        .attr('markerWidth', (d)-> d.markerWidth)
        .append('svg:path')
          .attr('d', (d)-> d.path)
          .attr('fill', (d)=> 
            if d.get('fill') is 'none'
              return @model.get('stroke')
            else
              return d.get('fill')
          )
          .attr('fill-opacity', (d)-> return d.get('fill_opacity'))
          .attr('stroke', (d)-> return d.get('stroke'))
          .attr('stroke-opacity', (d)-> return d.get('stroke_opacity'))
          .attr('stroke-width', (d)-> return d.get('stroke'))

    @marker_start.exit().remove()
    @marker_end.exit().remove()


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
        .attr('r', 7)
        .attr('fill', '#4d4d4d')
        .attr('stroke', '#fff')
        .attr('stroke-width', 2)
        .attr('cursor', 'move')
        .call(d3.behavior.drag()
          .on('dragstart', @drag_endpoint_start)
          .on('drag', @drag_endpoint_move)
          .on('dragend', @drag_endpoint_end))

    midpoint_data = []
    _.each(@model.get('midpoints'), (d,i)=>
      midpoint_data.push { x: d[0], y: d[1] }
    )
    @controls.selectAll('circle.midpoint').remove()
    @midpoints = @controls.selectAll('circle.midpoint')
      .data(midpoint_data)

    @midpoints
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
    @midpoints
      .exit()
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
      .remove()


  # ----------------------------------
  # Endpoint Methods
  # ----------------------------------

  drag_endpoint_start: (d,i) =>
    @selected_endpoint = d

  drag_endpoint_move: (d,i) =>
    @selected_endpoint = null
    d.x = d3.event.x
    d.y = d3.event.y
    d3.select(@endpoints[0][i])
      .attr('cx', (d)-> return d.x)
      .attr('cy', (d)-> return d.y)

  drag_endpoint_end: (d,i) =>
    if @selected_endpoint is null
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
    _midpoints = d.get('midpoints')
    _new = [[d3.event.sourceEvent.offsetX,d3.event.sourceEvent.offsetY]]
    @model.save midpoints: _.union(_midpoints, _new)
    @build_points()
    mediator.publish 'refresh_canvas'

  destroy_midpoint: =>
    _midpoints = @model.get('midpoints')
    _midpoints.splice(@selected_midpoint.index, 1)
    @model.save midpoints: _midpoints
    @selected_midpoint = null
    @build_points()
    mediator.publish 'refresh_canvas'

  drag_midpoint_start: (d,i) =>
    @midpoints.classed('active', false)
    d3.select(@midpoints[0][i]).classed('active', true)
    @selected_midpoint = d
    @selected_midpoint.index = i

  drag_midpoint_move: (d,i) =>
    d.x = d3.event.x
    d.y = d3.event.y
    d3.select(@midpoints[0][i])
      .attr('cx', (d)-> return d.x)
      .attr('cy', (d)-> return d.y)

  drag_midpoint_end: (d,i) =>
    _midpoints = @model.get('midpoints')
    _midpoints[i][0] = d.x
    _midpoints[i][1] = d.y
    @model.save midpoints: _midpoints
    mediator.publish 'refresh_canvas'
      




  # ----------------------------------
  # GENERATE Markers
  # ----------------------------------
  generate_marker_path: (d) =>
    stroke_width = @model.get('stroke_width')
    type = d.get('type')
    width = d.get('width')
    _w = 2 * stroke_width
    _scale = width / stroke_width
    
    switch type
      when 'none'
        d.markerHeight = 0
        d.markerWidth = 0
        d.path = 'M 0,0'
        d.viewbox = '0 0 0 0'
        break
      
      when 'circle'
        _min = -1 * stroke_width
        _max = stroke_width
        d.markerHeight = _scale
        d.markerWidth = _scale
        d.path = 'M 0,0  m ' + _min + ',0  a ' + _max + ',' + _max + ' 0 1,0 ' + _w + ',0  a ' + _max + ',' + _max + ' 0 1,0 ' +  _w*-1 + ',0'
        d.viewbox = '' + _min + ' ' + _min + ' ' + _w + ' ' + _w
        break
      
      when 'square'
        _min = -1 * stroke_width
        _max = stroke_width
        d.markerHeight = _scale
        d.markerWidth = _scale
        d.path = 'M ' + _min + ',' + _min + ' L' + _max + ',' + _min + ' L' + _max + ',' + _max + ' L' + _min + ',' + _max + ' Z'
        d.viewbox = '' + _min + ' ' + _min + ' ' + _w + ' ' + _w
        break
      
      when 'reverse-start'
        _min_x = 0
        _max_x = _w
        _min_y = -1 * stroke_width/2
        _max_y = stroke_width/2
        d.markerHeight = 1 * _scale
        d.markerWidth = 2 * _scale
        d.path = 'M 0,0 m 0,' + _min_y + ' L ' + _max_x + ',0 L 0,' + _max_y + ' z'
        d.viewbox = '' + _min_x + ' ' + _min_y + ' ' + _w + ' ' + stroke_width
        break
      
      when 'reverse-end'
        _min_x = -2 * stroke_width
        _min_y = -1 * stroke_width/2
        _max_y = stroke_width/2
        d.markerHeight = 1 * _scale
        d.markerWidth = 2 * _scale
        d.path = 'M 0,0 m 0,' + _min_y + ' L ' + _min_x + ',0 L 0,' + _max_y + ' z'
        d.viewbox = '' + _min_x + ' ' + _min_y + ' ' + _w + ' ' + stroke_width
        break

    #@marker_end
    #    .attr('viewBox', '0 -5 10 10')
    #    .attr('markerHeight', 3)
    #    .attr('markerWidth', 4)
    #    .append('svg:path')
    #      .attr('d', 'M 0,0 m 0,-5 L 10,0 L 0,5 z')
    #      .attr('fill', '#333333')

