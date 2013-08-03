mediator = require 'mediator'
View = require 'views/base/view'

zoom_helpers = require '/editor/lib/zoom-helpers'

module.exports = class ToolAxisView extends View
  
  initialize: ->
    super
    console.log 'Initializing ToolAxisView'
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-axis').addClass('active')
    
    mediator.outer.attr('cursor', 'crosshair')
    d3.select('#canvas_elements_background')
      .call(d3.behavior.drag()
        .on('dragstart', @start_line)
        .on('drag', @draw_line)
        .on('dragend', @set_line))
    
    @nodes = d3.selectAll('g.nodeGroup').attr('pointer-events', 'none')
    @links = d3.selectAll('g.linkGroup').attr('pointer-events', 'none')
    
    @start_point = null
    @end_point = null
    @ghost_line = null

  remove: ->
    mediator.outer.attr('cursor', 'default')
    d3.select('#canvas_elements_background')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
    @nodes.attr('pointer-events', 'all')
    @links.attr('pointer-events', 'visibleStroke')
    @nodes = null
    @links = null
    @deactivate()

    # Unbind @el ------------------
    @setElement('')
    super

  deactivate: ->
    @reset()

  reset: =>
    @ghost_line?.remove()
    @start_point = null
    @end_point = null

  start_line: =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = zoom_helpers.get_coordinates(e)
    @reset()

    @start_point=
      x: coordinates.x
      y: coordinates.y
    
    @ghost_line = mediator.controls.selectAll('g#newAxis')
      .data([@start_point])
    @ghost_line
      .enter()
      .append('svg:g')
        .attr('id', '#newAxis')
        .append('svg:line')
          .attr('id', 'ghost_line')
          .attr('x1', (d)-> return d.x)
          .attr('y1', (d)-> return d.y)
          .attr('x2', (d)-> return d.x)
          .attr('y2', (d)-> return d.y)
          .attr('stroke', '#000')
          .attr('stroke-width', 1)
    @ghost_line
      .exit()
      .remove()

  draw_line: =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    if @start_point?
      coordinates = zoom_helpers.get_coordinates(e)
      @drag_point=
        x: coordinates.x
        y: coordinates.y

      _pair = [@drag_point.x - @start_point.x, @drag_point.y - @start_point.y]
      #theta = Math.atan2(-_pair[1], _pair[0])
      #if (theta < 0)
      #  theta += 2 * Math.PI
      #_angle = theta * (180/Math.PI)
      #if (_angle > 30 and _angle < 60)
      #  _x2 = @start_point.x + Math.abs(_pair[0])
      #  _y2 = @start_point.y - Math.abs(_pair[0])
      
      if Math.abs(@start_point.x - @drag_point.x) > Math.abs(@start_point.y - @drag_point.y)
        @drag_point.y = @start_point.y
        @rotation = (if (_pair[0] < 0) then 180 else 0)
      else
        @drag_point.x = @start_point.x
        @rotation = (if (_pair[1] < 0) then 270 else 90)

      @end_point=
        x: @drag_point.x
        y: @drag_point.y

      @ghost_line.select('#ghost_line')
        .attr('x2', @end_point.x)
        .attr('y2', @end_point.y)

  set_line: =>
    if @start_point? and @end_point?
      _cx = (@start_point.x + @end_point.x) / 2
      _cy = (@start_point.y + @end_point.y) / 2 
      if @rotation is 0
        _start = [_cx - @end_point.x, _cy - @end_point.y]
        _end   = [_cx - @start_point.x, _cy - @start_point.y]
      else if @rotation is 90
        _start = [_cy - @end_point.y, _cx - @end_point.x]
        _end   = [_cy - @start_point.y, _cx - @start_point.x]
      else if @rotation is 180
        _start = [_cx - @start_point.x, _cy - @start_point.y]
        _end   = [_cx - @end_point.x, _cy - @end_point.y]
      else if @rotation is 270
        _start = [_cy - @start_point.y, _cx - @start_point.x]
        _end   = [_cy - @end_point.y, _cx - @end_point.x]
      
      _axis=
        endpoints: [_start,_end]
        rotate: @rotation
        x: _cx
        y: _cy
      mediator.axes.create _axis, {wait: true}
    @deactivate()


