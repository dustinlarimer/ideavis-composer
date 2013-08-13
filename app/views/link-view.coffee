mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class LinkView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super

    try
      @zoom_helpers = require '/editor/lib/zoom-helpers'
      @mode = 'private'
    catch error
      @mode = 'public'
    
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
    @selected_midpoint = null
    
    @subscribeEvent 'clear_active', @clear

    @listenTo @model, 'change', @build_baseline
    #@listenTo @model.marker_start, 'change', @build_markers
    #@listenTo @model.marker_end, 'change', @build_markers

  render: ->
    super
    @build_baseline()
    console.log '[LinkView Rendered]'

  remove: ->
    @zoom_helpers = null
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
    d3.select(@el).classed('active', true)
    @baseline.attr('visibility', 'hidden')
    @tickline
      .attr('visibility', 'visible')
      .call(d3.behavior.drag()
        .on('dragstart', @create_midpoint))
    @build_points()

  deactivate: ->
    @selected_endpoint = null
    @selected_midpoint = null
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
  # BUILD Baseline
  # ----------------------------------
  build_baseline: =>
    @build_markers()
    
    @baseline = @baseline.data([@model])
    @baseline
      .enter()
      .append('svg:path')
      .attr('class', 'baseline')
      .attr('pointer-events', 'stroke')
      .attr('visibility', 'visible')
      .attr('opacity', (d)-> d.get('stroke_opacity')/100)
      .attr('shape-rendering', 'geometricPrecision')
      .attr('stroke', (d)-> d.get('stroke'))
      .attr('stroke-dasharray', (d)-> d.get('stroke_dasharray'))
      .attr('stroke-linecap', (d)-> d.get('stroke_linecap'))
      .attr('stroke-linejoin', (d)-> d.get('stroke_linecap'))
      .attr('stroke-width', (d)-> d.get('stroke_width'))
      .attr('fill', (d)-> d.get('fill'))
      .attr('marker-start', (d)-> 'url(#' + 'link_' + d.id + '_marker_start)')
      .attr('marker-end',   (d)-> 'url(#' + 'link_' + d.id + '_marker_end)')

    @baseline
      .attr('opacity', (d)-> d.get('stroke_opacity')/100)
      .attr('stroke', (d)-> d.get('stroke'))
      .attr('stroke-dasharray', (d)-> d.get('stroke_dasharray'))
      .attr('stroke-linecap', (d)-> d.get('stroke_linecap'))
      .attr('stroke-linejoin', (d)-> 
        _linecap = d.get('stroke_linecap')
        if _linecap is 'square' then return 'miter' else if _linecap is 'butt' then return 'bevel' else return _linecap
      )
      .attr('stroke-width', (d)-> d.get('stroke_width'))
      .attr('fill', (d)-> d.get('fill'))

    #d3.select(@el).select('path.tickline').remove()
    #tickline = d3.select(@el).selectAll('path.tickline').data([@model])

    @tickline = @tickline.data([@model])
    @tickline
      .enter()
      .append('svg:path')
        .attr('class', 'tickline')
        .attr('pointer-events', 'stroke')
        .attr('visibility', 'hidden')
        .attr('opacity', (d)-> d.get('stroke_opacity')/100)
        .attr('shape-rendering', 'geometricPrecision')
        .attr('stroke', (d)=> return @baseline.attr('stroke'))
        .attr('stroke-dasharray', (d)=> return @baseline.attr('stroke-dasharray'))
        .attr('stroke-linecap', (d)=> return @baseline.attr('stroke-linecap'))
        .attr('stroke-linejoin', (d)=> return @baseline.attr('stroke-linejoin'))
        .attr('stroke-width', (d)=> return @baseline.attr('stroke-width'))
        #.attr('stroke-width', (d)=> 
        #  _sw = @baseline.attr('stroke-width')
        #  if _sw < 8 then return 8 else return _sw
        #)
        .attr('fill', (d)=> return @baseline.attr('fill'))
        .attr('marker-start', (d)-> 'url(#' + 'link_' + d.id + '_marker_start)')
        .attr('marker-end',   (d)-> 'url(#' + 'link_' + d.id + '_marker_end)')

    @tickline
      .attr('opacity', (d)=> return @baseline.attr('opacity'))
      .attr('stroke', (d)=> return @baseline.attr('stroke'))
      .attr('stroke-dasharray', (d)=> return @baseline.attr('stroke-dasharray'))
      .attr('stroke-linecap', (d)=> return @baseline.attr('stroke-linecap'))
      .attr('stroke-linejoin', (d)=> return @baseline.attr('stroke-linejoin'))
      .attr('stroke-width', (d)=> return @baseline.attr('stroke-width'))
      .attr('fill', (d)=> return @baseline.attr('fill'))

    @label = @label.data([@model])
    @label
      .enter()
      .insert('text', 'path')
        .attr('fill', (d)=> d.get('label_fill'))
        .attr('fill-opacity', (d)=> d.get('label_fill_opacity')/100)
        .attr('font-family', 'Helvetica, sans-serif')
        .attr('font-size', (d)=> d.get('label_font_size'))
        .attr('font-style', (d)-> if d.get('label_italic') then return 'italic' else return 'normal')
        .attr('font-weight', (d)-> if d.get('label_bold') then return 'bold' else return 'normal')
        .append('svg:textPath')
          .attr('class', 'textpath')
          .attr('xlink:href', (d)=> '#link_' + d.id + '_path')
          .attr('letter-spacing', (d)=> d.get('label_spacing'))
          .attr('startOffset', (d)=>
            _align = d.get('label_align')
            _offset = d.get('label_offset_x')
            if _align is 'start' then return _offset + '%' else if _align is 'end' then return (100 - _offset) + '%' else return '50%'
          )
          .attr('text-anchor', (d)=> d.get('label_align'))
          .append('svg:tspan')
            .attr('class', 'tspan')
            .attr('dy', (d)=> -1 * d.get('label_offset_y'))
            .text((d)=> d.get('label_text'))

    @label
      .attr('fill', (d)=> d.get('label_fill'))
      .attr('fill-opacity', (d)=> d.get('label_fill_opacity')/100)
      .attr('font-size', (d)=> d.get('label_font_size'))
      .attr('font-style', (d)-> if d.get('label_italic') then return 'italic' else return 'normal')
      .attr('font-weight', (d)-> if d.get('label_bold') then return 'bold' else return 'normal')
      .transition()
        .ease('linear')
        .selectAll('.textpath')
          .attr('letter-spacing', (d)=> d.get('label_spacing'))
          #.attr('startOffset', (d)=> d.get('label_offset_x'))
          .attr('startOffset', (d)=>
            _align = d.get('label_align')
            _offset = d.get('label_offset_x')
            if _align is 'start' then return _offset + '%' else if _align is 'end' then return (100 - _offset) + '%' else return '50%'
          )
          .attr('text-anchor', (d)=> d.get('label_align'))
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
        .attr('markerUnits', 'userSpaceOnUse')
        .attr('orient', 'auto')
        .attr('refY', 0)
        .append('svg:path')

    @marker_start
        .each((d,i)=> @generate_marker_path(d))
        .attr('refX', (d)=> return -1 * d.get('offset_x'))
        .attr('viewBox', (d)-> d.viewbox)
        .attr('markerHeight', (d)-> d.markerHeight)
        .attr('markerWidth', (d)-> d.markerWidth)
        .selectAll('path')
          .attr('d', (d)-> d.path)
          .attr('fill', (d)=> 
            if d.get('fill') is 'none'
              return @model.get('stroke')
            else
              return d.get('fill')
          )

    @marker_end = @marker_end.data([@model.marker_end])
    @marker_end
      .enter()
      .append('svg:marker')
        .attr('id', 'link_' + @model.id + '_marker_end')
        .attr('class', 'marker-end')
        .attr('markerUnits', 'userSpaceOnUse')
        .attr('orient', 'auto')
        .attr('refY', 0)
        .append('svg:path')
    
    @marker_end
        .each((d,i)=> @generate_marker_path(d))
        .attr('refX', (d)=> return d.get('offset_x'))
        .attr('viewBox', (d)-> d.viewbox)
        .attr('markerHeight', (d)-> d.markerHeight)
        .attr('markerWidth', (d)-> d.markerWidth)
        .selectAll('path')
          .attr('d', (d)-> d.path)
          .attr('fill', (d)=> 
            if d.get('fill') is 'none'
              return @model.get('stroke')
            else
              return d.get('fill')
          )

    @marker_start.exit().remove()
    @marker_end.exit().remove()


  # ----------------------------------
  # BUILD Points
  # ----------------------------------
  build_points: =>
    console.log 'building points'
    
    mediator.controls.selectAll('g#link_controls').remove()
    @controls = mediator.controls
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
        .attr('class', 'point endpoint')
        #.style('filter', 'url(#link_point_drop_shadow)')
        .attr('cx', (d)-> return d.x)
        .attr('cy', (d)-> return d.y)
        .attr('r', 5)
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
        .attr('class', 'point midpoint')
        #.style('filter', 'url(#link_point_drop_shadow)')
        .attr('cx', (d)-> return d.x)
        .attr('cy', (d)-> return d.y)
        .attr('r', 5)
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
    d3.event.sourceEvent.stopPropagation()
    @selected_endpoint = d

  drag_endpoint_move: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
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
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = @zoom_helpers.get_coordinates(e)
    
    _new = [[ coordinates.x, coordinates.y ]]
    _endpoints = d.get('endpoints')
    _endpoint_source = [ (@source.x+_endpoints[0][0]), (@source.y+_endpoints[0][1]) ]
    _endpoint_target = [ (@target.x+_endpoints[1][0]), (@target.y+_endpoints[1][1]) ]
    _midpoints = d.get('midpoints')
    
    if _midpoints.length > 0
      _check = []
      _check.push _endpoint_source
      _.each(_midpoints, (d,i)-> _check.push d)
      _check.push _endpoint_target
    
      place = null
      before = []
      after = []
      _.each(_check, (d,i)=>
        if (_check[i][0] < _new[0][0] and _new[0][0] < _check[i+1]?[0]) or (_check[i][0] > _new[0][0] and _new[0][0] > _check[i+1]?[0])
          if (_check[i][1] < _new[0][1] and _new[0][1] < _check[i+1]?[1]) or (_check[i][1] > _new[0][1] and _new[0][1] > _check[i+1]?[1])
            if (_check.length-1) is (i+1)
              place = 'append'
            else if i is 0
              place = 'prepend'
            before = _check[i]
            after  = _check[i+1]
      )

      if place is 'append'
        @model.save midpoints: _.union(_midpoints, _new)
      else if place is 'prepend'
        @model.save midpoints: _.union(_new, _midpoints)
      else
        index = _midpoints.indexOf(after)
        _modified = _midpoints.splice(index, 0, _new[0])
        @model.save midopints: _modified
    else
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
    d3.event.sourceEvent.stopPropagation()
    @midpoints.classed('active', false)
    d3.select(@midpoints[0][i]).classed('active', true)
    @selected_midpoint = d
    @selected_midpoint.index = i

  drag_midpoint_move: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
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
    #_width = d.get('width')
    #_scale = width / stroke_width
    
    switch type
      when 'none'
        d.markerHeight = 1
        d.markerWidth = 1
        d.path = 'M 0,0'
        d.viewbox = '0 0 0 0'
        break

      when 'circle'
        _r = d.get('width') / 2
        d.markerHeight = width
        d.markerWidth = width
        d.path = '' + 
          'M 0,0 ' +
          'm ' + (_r*-1) + ',0 ' +
          'a ' + _r + ',' + _r + ' 0 1,0 ' + (_r*2)  + ',0 ' +
          'a ' + _r + ',' + _r + ' 0 1,0 ' + (_r*-2) + ',0 ' +
          ''
        d.viewbox = '' + (_r*-1) + ' ' + (_r*-1) + ' ' + (_r*2) + ' ' + (_r*2)
        break
   
      when 'square'
        _min = -1 * width / 2
        _max = width / 2
        d.markerHeight = width
        d.markerWidth = width
        d.path = '' +
          'M ' + _min + ',' + _min + ' ' +
          'L ' + _max + ',' + _min + ' ' +
          'L ' + _max + ',' + _max + ' ' +
          'L ' + _min + ',' + _max + ' Z'+
          ''
        d.viewbox = '' + _min + ' ' + _min + ' ' + d.markerWidth + ' ' + d.markerHeight
        break

      when 'stem'
        _min_x = -1 * width / 8
        _min_y = -1 * width / 2
        _max_x = width / 8
        _max_y = width / 2
        d.markerHeight = width
        d.markerWidth = 4 * _max_x
        d.path = '' +
          'M ' + _min_x + ',' + _min_y + ' ' +
          'L ' + _max_x + ',' + _min_y + ' ' +
          'L ' + _max_x + ',' + _max_y + ' ' +
          'L ' + _min_x + ',' + _max_y + ' Z'+
          ''
        d.viewbox = '' + _min_x + ' ' + _min_y + ' ' + d.markerWidth + ' ' + d.markerHeight
        break

      when 'equal-arrow-start'
        _length = (1/2) * Math.sqrt(3) * width
        _min_x = -1 * _length
        _min_y = -1 * width / 2
        _max_y = width / 2
        d.markerHeight = width
        d.markerWidth = _length
        d.path = '' +
          'M 0,' + _min_y + ' ' +
          'L ' + _min_x + ',0 ' +
          'L 0,' + _max_y + ' Z'
        d.viewbox = '' + _min_x + ' ' + _min_y + ' ' + d.markerWidth + ' ' + d.markerHeight
        break
      when 'equal-arrow-end'
        _length = (1/2) * Math.sqrt(3) * width
        _max_x = _length
        _min_y = -1 * width / 2
        _max_y = width / 2
        d.markerHeight = width
        d.markerWidth = _length
        d.path = '' +
          'M 0,' + _min_y + ' ' +
          'L ' + _max_x + ',0 ' +
          'L 0,' + _max_y + ' Z'
        d.viewbox = '0 ' + _min_y + ' ' + d.markerWidth + ' ' + d.markerHeight
        break

      when 'right-arrow-start'
        _min_x = -1 * width / 2
        _min_y = -1 * width / 2
        _max_y = width / 2
        d.markerHeight = width
        d.markerWidth = width / 2
        d.path = '' +
          'M 0,' + _min_y + ' ' +
          'L ' + _min_x + ',0 ' +
          'L 0,' + _max_y + ' Z'
        d.viewbox = '' + _min_x + ' ' + _min_y + ' ' + d.markerWidth + ' ' + d.markerHeight
        break
      when 'right-arrow-end'
        _max_x = width / 2
        _min_y = -1 * width / 2
        _max_y = width / 2
        d.markerHeight = width
        d.markerWidth = width / 2
        d.path = '' +
          'M 0,' + _min_y + ' ' +
          'L ' + _max_x + ',0 ' +
          'L 0,' + _max_y + ' Z'
        d.viewbox = '0 ' + _min_y + ' ' + d.markerWidth + ' ' + d.markerHeight
        break

      when 'sharp-arrow-start'
        _length = .6 * width
        _min_x = -1 * _length
        _min_y = -1 * width / 2
        _max_y = width / 2
        d.markerHeight = width
        d.markerWidth = width + width/5
        d.path = '' +
          'M 0,0 ' +
          'L ' + (width/5) + ',' + _min_y + ' ' +
          'L ' + _min_x + ',0 ' +
          'L ' + (width/5) + ',' + _max_y + ' Z'
        d.viewbox = '' + _min_x + ' ' + _min_y + ' ' + d.markerWidth + ' ' + d.markerHeight
        break
      when 'sharp-arrow-end'
        _length = .6 * width
        _max_x = _length
        _min_y = -1 * width / 2
        _max_y = width / 2
        d.markerHeight = width
        d.markerWidth = width + width/5
        d.path = '' +
          'M 0,0 ' +
          'L ' + (-1*width/5) + ',' + _min_y + ' ' +
          'L ' + _max_x + ',0 ' +
          'L ' + (-1*width/5) + ',' + _max_y + ' Z'
        d.viewbox = '' + (-1*width/5) + ' ' + _min_y + ' ' + d.markerWidth + ' ' + d.markerHeight
        break

      when 'reverse-start'
        _min_x = 0
        _max_x = 2 * width
        _min_y = -1 * width / 2
        _max_y = width / 2
        d.markerHeight = width
        d.markerWidth = 2 * width
        d.path = 'M 0,0 m 0,' + _min_y + ' L ' + _max_x + ',0 L 0,' + _max_y + ' z'
        d.viewbox = '' + _min_x + ' ' + _min_y + ' ' + d.markerWidth + ' ' + d.markerHeight
        break
      when 'reverse-end'
        _min_x = -2 * width
        _min_y = -1 * width / 2
        _max_y = width / 2
        d.markerHeight = 1 * width
        d.markerWidth = 2 * width
        d.path = 'M 0,0 m 0,' + _min_y + ' L ' + _min_x + ',0 L 0,' + _max_y + ' z'
        d.viewbox = '' + _min_x + ' ' + _min_y + ' ' + d.markerWidth + ' ' + d.markerHeight
        break
