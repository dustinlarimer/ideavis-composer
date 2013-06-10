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
    #_.extend EditorView.prototype, CanvasView.prototype
    _.bindAll this, 'mousemove', 'mousedown', 'mouseup'
    
    #d3.select(window).on('keydown', @keydown)
    $('#stage svg').on 'mousemove', @mousemove
    $('#stage svg').on 'mousedown', @mousedown
    $('#stage svg').on 'mouseup', @mouseup
    
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
        nodes.splice nodes.indexOf(selected_node), 1  if selected_node
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
    console.log '» mousemove'
  
  mouseup: (e) ->
    console.log '» mouseup'
    unless mouseup_node?
      console.log @model
      @model.addNode x: e.offsetX, y: e.offsetY
      @resetMouseVars


  # ----------------------------------
  # NODE GROUP METHODS (OVERRIDE)
  # ----------------------------------

  drag_group_end: (d, i) ->
    d.set({x: d3.event.sourceEvent.x, y: d3.event.sourceEvent.y})
    super