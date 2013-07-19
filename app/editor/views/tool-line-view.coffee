mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ToolLineView extends View
  
  initialize: ->
    super
    console.log 'Initializing ToolLineView'
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-line').addClass('active')
    mediator.outer.attr('cursor', 'crosshair')
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

    @deactivate()

    # Unbind @el ------------------
    @setElement('')
    
    mediator.outer.attr('cursor', 'default')
    super

  deactivate: ->
    @start_point = null
    @end_point = null
    @ghost_line?.remove()
    mediator.zoom = true

  start_line: (e) =>
    console.log 'Starting a line'
    mediator.zoom = false
    @ghost_line?.remove()
    @start_point = null
    @end_point = null
    
    _parent = $(e.target.nextElementSibling)[0].getBoundingClientRect()
    _x = null
    _y = null
    
    if _parent.left > 50
      console.log '> 0'
      _x = (e.clientX-50) - (_parent.left-50)
    else
      console.log '< 0'
      _x = Math.abs(_parent.left-50) + (e.clientX-50)
    
    if _parent.top > 50
      _y = (e.clientY-50) - (_parent.top-50)
    else
      _y = Math.abs(_parent.top-50) + (e.clientY-50)
    
    @start_point=
      x: _x
      y: _y
    
    @ghost_line = mediator.controls.selectAll('g#newLine')
      .data([@start_point])
    @ghost_line
      .enter()
      .append('svg:g')
        .attr('id', '#newLine')
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
      #console.log 'Drawing a line'
      _parent = $(e.target.nextElementSibling)[0].getBoundingClientRect()
      _x2 = null
      _y2 = null
      if _parent.left > 50
        _x2 = (e.clientX-50) - (_parent.left-50)
      else
        _x2 = Math.abs(_parent.left-50) + (e.clientX-50)
      
      if _parent.top > 50
        _y2 = (e.clientY-50) - (_parent.top-50)
      else
        _y2 = Math.abs(_parent.top-50) + (e.clientY-50)

      #if key.shift

      console.log @start_point.y
      console.log _y2

      if Math.abs(@start_point.x - _x2) > Math.abs(@start_point.y - _y2)
        #or (Math.abs(_x2-@start_point.x) > Math.abs(_y2-@start_point.y))
        _y2 = @start_point.y
      else
        _x2 = @start_point.x

      @end_point=
        x: _x2
        y: _y2

      @ghost_line.select('#ghost_line')
        .attr('x2', @end_point.x)
        .attr('y2', @end_point.y)

  set_line: (e) =>
    if @start_point? and @end_point?
      console.log 'creating new line!'
      _line=
        endpoints: [[@start_point.x, @start_point.y],[@end_point.x,@end_point.y]]
      console.log _line
      #mediator.lines.create {}, {wait: true}
    @deactivate()


