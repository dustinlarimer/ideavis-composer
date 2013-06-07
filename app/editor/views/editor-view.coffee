View = require 'views/base/view'
template = require 'editor/views/templates/editor'

module.exports = class EditorView extends View
  el: '#editor'
  template: template
  regions:
    '#editor': 'editor'
  
  initialize: ->
    super
    console.log 'Initializing EditorView'
    @subscribeEvent 'canvas_rendered', @render()
    
    #@delegate 'mousemove', 'svg > g', @mousemove
    #@delegate 'mousedown', 'svg > g', @mousedown
    #@delegate 'mouseup', 'svg > g', @mouseup
    #d3.select(window).on("keydown", @keydown)

    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

  render: ->
    super
    console.log '[...] Rendering EditorView'

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