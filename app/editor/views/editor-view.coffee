View = require 'views/base/view'
template = require 'views/templates/canvas'

CanvasView = require 'views/canvas-view'

module.exports = class EditorView extends View
  el: '#canvas'
  regions:
    '#controls': 'controls'
    '#stage': 'stage'
  
  initialize: ->
    super
    console.log 'Ready to rock'
    
    #@delegate 'mousemove', 'svg > g', @mousemove
    #@delegate 'mousedown', 'svg > g', @mousedown
    #@delegate 'mouseup', 'svg > g', @mouseup
    d3.select(window).on("keydown", @keydown)

    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

  shortcuts:
    'shift+t' : 'shifty'

  shifty: ->
    console.log 'Keyboard shortcuts enabled'

  keydown: ->
    console.log 'Keycode ' + d3.event.keyCode + ' pressed.'
    switch d3.event.keyCode
      when 8, 46
        nodes.splice nodes.indexOf(selected_node), 1  if selected_node
        selected_node = null
        @draw()
        break