mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ToolLineView extends View
  
  initialize: ->
    super
    console.log 'Initializing ToolLineView'
    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-line').addClass('active')
    
    @delegate 'mousedown', '#canvas_elements_background', @start_line
    @delegate 'mousemove', '#canvas_elements_background', @draw_line
    @delegate 'mouseup', #canvas_elements_background', @set_line

  remove: ->
    # Unbind delgated events ------
    #@$el.off 'click', '#canvas_background'
    
    # Unbind @el ------------------
    @setElement('')
    
    console.log '[xx Node tool out! xx]'
    super

  start_line: (e) ->
    console.log 'Starting a line'

  draw_line: (e) ->
    console.log 'Drawing a line'

  set_line: (e) ->
    console.log 'Setting a line'
    #mediator.lines.create {}, {wait: true}