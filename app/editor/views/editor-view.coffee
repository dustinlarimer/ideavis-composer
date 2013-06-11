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
    super
    console.log 'Initializing EditorView'
    #_.extend EditorView.prototype, CanvasView.prototype
    #_.bindAll this, 'mousedown', 'mousemove', 'mouseup'
    
    d3.select(window).on('keydown', @keydown)
    
    #@delegate 'mousedown', '#stage svg', @mousedown
    #@delegate 'mousemove', '#stage svg', @mousemove
    #@delegate 'mouseup', '#stage svg', @mouseup
    #@delegate 'dblclick', 'svg g', @select_node_group
    
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

  render: ->
    super
    console.log 'Rendering EditorView [...]'


  # ----------------------------------
  # SELECTIONS
  # ----------------------------------

  selected_node = null
  selected_link = null
  mousedown_link = null
  mousedown_node = null
  mouseup_node = null
  keydown_code = null

  resetSelections: ->
    return null

  resetMouseVars: ->
    mousedown_node = null
    mouseup_node = null
    mousedown_link = null

  select_node_group: (e) ->
    console.log e


  # ----------------------------------
  # KEYBOARD METHODS
  # ----------------------------------

  shortcuts:
    'shift+t' : 'shifty'

  shifty: ->
    console.log 'Keyboard shortcuts enabled'
    #mediator.node.call(drag_group)

  keydown: ->
    console.log 'Keycode ' + d3.event.keyCode + ' pressed.'
    switch d3.event.keyCode
      when 8, 46
        #mediator.nodes.splice mediator.nodes.indexOf(selected_node), 1  if selected_node
        #console.log selected_node
        selected_node = null
        @draw()
        break


  # ----------------------------------
  # MOUSE METHODS
  # ----------------------------------

  mousedown: ->
    console.log '» mousedown'
    unless mousedown_node?
      selected_node = null
      #@draw()

  mousemove: ->
    #console.log '» mousemove'
  
  mouseup: (e) ->
    console.log '» mouseup'
    unless mouseup_node?
      @model.addNode x: e.offsetX, y: e.offsetY
      @resetMouseVars


  # ----------------------------------
  # NODE GROUP METHODS (OVERRIDE)
  # ----------------------------------

  drag_group_start: (d, i) ->
    console.log d
    selected_node = d
    super

  drag_group_move: (d, i) ->
    selected_node = null
    super

  drag_group_end: (d, i) ->
    console.log selected_node
    if !selected_node?
      d.set({x: d3.event.sourceEvent.layerX, y: d3.event.sourceEvent.layerY})
    else
      console.log '»» Node has been selected ««'
      console.log selected_node
      selected_node.view.dispose()
      selected_node.destroy()
      @resetMouseVars()
    super







