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
    _.bindAll this, 'keydown' #, 'drag_group_move' #, 'mouseup'
    
    d3.select(window).on('keydown', @keydown)
    d3.select(window).on('keyup', @keyup)
    
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

  selected_node_group = null
  mousedown_node      = null
  mouseup_node        = null

  reset_selections: ->
    selected_node_group = null
    mousedown_node      = null
    mouseup_node        = null

  select_node_group: (e) ->
    console.log e


  # ----------------------------------
  # KEYBOARD METHODS
  # ----------------------------------

  key_selection = null

  shortcuts:
    'shift+t' : 'shifty'

  shifty: ->
    console.log 'Keyboard shortcuts enabled'
    #mediator.node.call(drag_group)

  keydown: ->
    #console.log 'Keycode ' + d3.event.keyCode + ' pressed.'
    key_selection = d3.event.keyCode
    switch d3.event.keyCode
      when 8, 46
        d3.event.preventDefault() if d3.event
        @destroy_node_group(selected_node_group) if selected_node_group
        @reset_selections()
        break
      when 32
        d3.event.preventDefault() if d3.event
        break
      when 91
        console.log 'Cmnd'
        break

  keyup: ->
    key_selection = null


  # ----------------------------------
  # MOUSE METHODS
  # ----------------------------------

  mousedown: ->
    console.log '» mousedown'
    unless mousedown_node?
      selected_node_group = null

  mousemove: ->
    #console.log '» mousemove'
  
  mouseup: (e) ->
    console.log '» mouseup'
    unless mouseup_node?
      @model.addNode x: e.offsetX, y: e.offsetY
      @reset_selections


  # ----------------------------------
  # NODE GROUP METHODS (OVERRIDE)
  # ----------------------------------

  drag_group_start: (d, i) ->
    console.log d
    console.log selected_node_group
    if selected_node_group and key_selection is 91
      console.log '! Ready to pair'
    else
      @publishEvent 'clear_active_nodes'
      selected_node_group = d
    super

  drag_group_move: (d, i) ->
    selected_node_group = null
    super

  drag_group_end: (d, i) ->
    if !selected_node_group?
      @publishEvent 'clear_active_nodes'
      d.set({x: d3.event.sourceEvent.layerX, y: d3.event.sourceEvent.layerY})
    else
      console.log '»» Node Group selected ««'
      console.log selected_node_group
      selected_node_group.view.activate()
      #@reset_selections()
    super

  destroy_node_group: (node_group) ->
    node_group.view.dispose()
    node_group.destroy()





