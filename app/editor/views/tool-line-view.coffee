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
    
    @delegate 'mousedown', '#canvas_elements_background', @start_line
    @delegate 'mousemove', '#canvas_elements_background', @draw_line
    @delegate 'mouseup'  , '#canvas_elements_background', @set_line

  remove: ->
    # Unbind delgated events ------
    @$el.off 'mousedown', '#canvas_elements_background'
    @$el.off 'mousemove', '#canvas_elements_background'
    @$el.off 'mouseup', '#canvas_elements_background'
    
    # Unbind @el ------------------
    @setElement('')
    
    console.log '[xx Node tool out! xx]'
    mediator.outer.attr('cursor', 'default')
    mediator.zoom = true
    super

  start_line: (e) =>
    mediator.zoom = false
    console.log e.clientX
    console.log $(e.target.nextElementSibling)[0].getBBox()
    console.log $(e.target.nextElementSibling)[0].getBoundingClientRect()
    console.log mediator.offset[0]

    # if _parent.left > 0, subtract 50
    # if _parent.left < 0, Math.abs() that shit
    # == more accurate than mediator.offset[0]

    _parent = $(e.target.nextElementSibling)[0].getBoundingClientRect()
    if _parent < 0
      console.log e.clientX + Math.abs($(e.target.nextElementSibling)[0].getBoundingClientRect().left)
    else
      console.log e.clientX-50
    
    #@start_point = 
    console.log 'Starting a line'

  draw_line: (e) =>
    mediator.zoom = false
    console.log 'Drawing a line'

  set_line: (e) =>
    console.log 'Setting a line'
    #mediator.lines.create {}, {wait: true}
    mediator.zoom = true