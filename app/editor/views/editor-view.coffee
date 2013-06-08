mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/editor'

CanvasView = require 'views/canvas-view'

module.exports = class EditorView extends CanvasView
  el: '#canvas'
  template: template
  regions:
    '#controls' : 'controls'
    '#stage'    : 'stage'
  
  initialize: ->
    console.log 'Initializing EditorView'
    super
    _.bindAll this, 'mousemove', 'mousedown', 'mouseup'
    console.log @
    
    d3.select(window).on("keydown", @keydown)
    $('#stage svg').on 'mousemove', @mousemove
    $('#stage svg').on 'mousedown', @mousedown
    $('#stage svg').on 'mouseup', @mouseup

    #d3.selectAll('#stage svg g.nodeGroup').call(drag_group)

    #$('#stage svg g.nodeGroup').on 'dragstart', @drag_group_start
    #$('#stage svg g.nodeGroup').on 'drag', @drag_group_move
    #$('#stage svg g.nodeGroup').on 'dragend', @drag_group_end
    @subscribeEvent 'node_group_dragged', @update_node_position
    
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

  render: ->
    super
    console.log 'Rendering EditorView [...]'
    #console.log mediator.node #.call(drag_group)

  update_node_position: (data) ->
    console.log data
    data.node.set({x: data.x, y: data.y})

  shortcuts:
    'shift+t' : 'shifty'

  shifty: ->
    console.log 'Keyboard shortcuts enabled'
    #mediator.node.call(drag_group)

  selected_node = null
  selected_link = null
  mousedown_link = null
  mousedown_node = null
  mouseup_node = null
  keydown_code = null

  keydown: ->
    console.log 'Keycode ' + d3.event.keyCode + ' pressed.'
    switch d3.event.keyCode
      when 8, 46
        nodes.splice nodes.indexOf(selected_node), 1  if selected_node
        selected_node = null
        @draw()
        break

  mousedown: ->
    console.log ':mousedown'
    unless mousedown_node?
      selected_node = null
      #@draw()

  mousemove: ->
    console.log ':mousemove'
  
  mouseup: (e) ->
    console.log ':mouseup'
    unless mouseup_node?
      console.log @model
      @model.addNode x: e.offsetX, y: e.offsetY
      @resetMouseVars

  resetMouseVars: ->
    mousedown_node = null
    mouseup_node = null
    mousedown_link = null

  dragmove: (d, i) ->
    d.px += d3.event.dx
    d.py += d3.event.dy
    d.x += d3.event.dx
    d.y += d3.event.dy
    force.tick()
  
  dragend: (d, i) ->
    force.tick()
    force.resume()

