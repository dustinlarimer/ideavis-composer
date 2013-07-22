mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ToolAxisView extends View
  
  initialize: ->
    super
    console.log 'Initializing ToolAxisView'
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-line').addClass('active')
    mediator.outer.attr('cursor', 'crosshair')
    
    @nodes = d3.selectAll('g.nodeGroup').attr('pointer-events', 'none')
    @links = d3.selectAll('g.linkGroup').attr('pointer-events', 'none')
    
    @start_point = null
    @end_point = null
    @ghost_line = null
    
    @delegate 'mousedown', '#canvas_elements_background', @start_line
    @delegate 'mousemove', '#canvas_elements_background', @draw_line
    @delegate 'mouseup'  , '#canvas_elements_background', @set_line

  remove: ->
    # Unbind delgated events ------
    @$el.off 'mousedown', '#canvas_elements_background'
    @$el.off 'mousemove', '#canvas_elements_background'
    @$el.off 'mouseup', '#canvas_elements_background'

    @nodes.attr('pointer-events', 'all')
    @links.attr('pointer-events', 'visibleStroke')
    @deactivate()

    # Unbind @el ------------------
    @setElement('')
    
    mediator.outer.attr('cursor', 'default')
    super

  deactivate: ->
    @reset()
    mediator.zoom = true

  reset: =>
    @ghost_line?.remove()
    @start_point = null
    @end_point = null

  start_line: (e) =>
    #console.log 'Starting a line'
    mediator.zoom = false
    @reset()
    
    _offset = $('#canvas_elements')[0].getBBox()
    _parent = $(e.target.nextElementSibling)[0].getBoundingClientRect()
    _x = null
    _y = null
    _scale = mediator.offset[1] or 1

    if _parent.left > 50
      #console.log '> 0'
      _x = (e.clientX-50) - (_parent.left-50) - Math.abs(_offset.x*_scale)
    else
      #console.log '< 0'
      _x = Math.abs(_parent.left-50) + (e.clientX-50) - Math.abs(_offset.x*_scale)
    
    if _parent.top > 50
      _y = (e.clientY-50) - (_parent.top-50) - Math.abs(_offset.y*_scale)
    else
      _y = Math.abs(_parent.top-50) + (e.clientY-50) - Math.abs(_offset.y*_scale)
    
    @start_point=
      x: _x / _scale
      y: _y / _scale
    
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

  draw_line: (e) =>
    mediator.zoom = false
    if @start_point?
      _offset = $('#canvas_elements')[0].getBBox()
      _parent = $(e.target.nextElementSibling)[0].getBoundingClientRect()
      _x2 = null
      _y2 = null
      _scale = mediator.offset[1] or 1
      
      if _parent.left > 50
        _x2 = (e.clientX-50) - (_parent.left-50) - Math.abs(_offset.x*_scale)
      else
        _x2 = Math.abs(_parent.left-50) + (e.clientX-50) - Math.abs(_offset.x*_scale)
      if _parent.top > 50
        _y2 = (e.clientY-50) - (_parent.top-50) - Math.abs(_offset.y*_scale)
      else
        _y2 = Math.abs(_parent.top-50) + (e.clientY-50) - Math.abs(_offset.y*_scale)

      _x2 = _x2 / _scale
      _y2 = _y2 / _scale

      _pair = [_x2 - @start_point.x, _y2 - @start_point.y]
      #theta = Math.atan2(-_pair[1], _pair[0])
      #if (theta < 0)
      #  theta += 2 * Math.PI
      #_angle = theta * (180/Math.PI)
      #if (_angle > 30 and _angle < 60)
      #  _x2 = @start_point.x + Math.abs(_pair[0])
      #  _y2 = @start_point.y - Math.abs(_pair[0])
      
      if Math.abs(@start_point.x - _x2) > Math.abs(@start_point.y - _y2)
        #or (Math.abs(_x2-@start_point.x) > Math.abs(_y2-@start_point.y))
        _y2 = @start_point.y
        @rotation = (if (_pair[0] < 0) then 180 else 0)
        #console.log @rotation
      else
        _x2 = @start_point.x
        @rotation = (if (_pair[1] < 0) then 90 else 270)
        #console.log @rotation

      @end_point=
        x: _x2
        y: _y2

      @ghost_line.select('#ghost_line')
        .attr('x2', @end_point.x)
        .attr('y2', @end_point.y)

  set_line: (e) =>
    if @start_point? and @end_point?
      console.log 'creating new line!'
      _axis=
        endpoints: [[@start_point.x, @start_point.y],[@end_point.x,@end_point.y]]
        rotation: @rotation
      #console.log _axis
      mediator.axes.create _axis, {wait: true}
    @deactivate()


