mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/editor'

module.exports = class EditorView extends View
  autoRender: true
  id: 'editor'
  containerMethod: 'prepend'
  template: template
  regions:
    '#editor': 'editor'
  
  initialize: ->
    console.log 'Initializing EditorView'
    super
    _.bindAll this, 'mousemove', 'mousedown', 'mouseup'
    
    d3.select(window).on("keydown", @keydown)
    $('#stage svg').on 'mousemove', @mousemove
    $('#stage svg').on 'mousedown', @mousedown
    $('#stage svg').on 'mouseup', @mouseup
    
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

  render: ->
    super
    console.log 'Rendering EditorView [...]'

  #update_node_attributes: (node, e) ->
  #  console.log node
  #  console.log e.x
  #  node.set({x: e.x, y: e.y})

  shortcuts:
    'shift+t' : 'shifty'

  shifty: ->
    console.log 'Keyboard shortcuts enabled'

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

  drag_group = d3.behavior.drag()
    .on('dragstart', @drag_group_start)
    .on('drag', @drag_group_move)
    .on('dragend', @drag_group_end)

  drag_group_start: (d, i) ->
    console.log 'starting drag'
    force.stop()

  drag_group_move: (d, i) ->
    d3.select(@).attr('transform', 'translate('+ d3.event.x + ',' + d3.event.y + ')')
    force.tick()
  
  drag_group_end: (d, i) ->
    nodes[i].set({x: d3.event.sourceEvent.x, y: d3.event.sourceEvent.y})
    console.log nodes.length
    force.tick()
    force.resume()

  dragmove: (d, i) ->
    d.px += d3.event.dx
    d.py += d3.event.dy
    d.x += d3.event.dx
    d.y += d3.event.dy
    force.tick()
  
  dragend: (d, i) ->
    force.tick()
    force.resume()

