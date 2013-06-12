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
    _.bindAll @, 'keydown'
    
    d3.select(window).on('keydown', @keydown)
    d3.select(window).on('keyup', @keyup)
    
    @delegate 'click', '#tool-pointer', @activate_pointer
    @delegate 'click', '#tool-node',    @activate_node
    @delegate 'click', '#tool-link',     @activate_link
    @delegate 'click', '#tool-text',    @activate_text
    
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
    'v'       : 'activate_pointer'
    'n'       : 'activate_node'
    'l'       : 'activate_link'
    't'       : 'activate_text'
    'shift+/' : 'help'

  shifty: ->
    console.log 'Keyboard shortcuts enabled'
    #mediator.node.call(drag_group)

  help: ->
    console.log 'Keyboard shortcuts:\n' + JSON.stringify(@shortcuts, null, 4)

  keydown: ->
    #console.log 'Keycode ' + d3.event.keyCode + ' pressed.'
    key_selection = d3.event.keyCode
    switch d3.event.keyCode
      when 8, 46
        d3.event.preventDefault() if d3.event
        @destroy_node_group(mediator.selected_node) if mediator.selected_node
        mediator.selected_node = null
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
      mediator.nodes.create x: e.offsetX, y: e.offsetY
      #@model.addNode x: e.offsetX, y: e.offsetY
      @reset_selections


  # ----------------------------------
  # NODE GROUP METHODS (OVERRIDE)
  # ----------------------------------

  clear_tool_selection: ->
    $('#toolbar button.active').removeClass('active')

  activate_pointer: (e) ->
    console.log 'Pointer tool active'
    if e.type is 'keydown'
      @clear_tool_selection()
      $('#toolbar button#tool-pointer').addClass('active')

  activate_node: (e) ->
    console.log 'Node tool active'
    if e.type is 'keydown'
      @clear_tool_selection()
      $('#toolbar button#tool-node').addClass('active')

  activate_link: (e) ->
    console.log 'Link tool active'
    if e.type is 'keydown'
      @clear_tool_selection()
      $('#toolbar button#tool-link').addClass('active')

  activate_text: (e) ->
    console.log 'Text tool active'
    if e.type is 'keydown'
      @clear_tool_selection()
      $('#toolbar button#tool-text').addClass('active')


  # ----------------------------------
  # NODE GROUP METHODS (OVERRIDE)
  # ----------------------------------

  _drag_group_start: (d, i) ->
    #console.log d3.select('g.nodeGroup')
    #console.log d
    #selection_parent = 
    #console.log d3.event.sourceEvent.target.parentElement.__data__
    #d = selection_parent if selection_parent.tagName is 'g'
    if selected_node_group and key_selection is 91
      console.log '! Ready to pair'
    else
      @publishEvent 'clear_active_nodes'
      selected_node_group = d
    super
  
  _drag_group_move: (d, i) ->
    selected_node_group = null
    super
  
  _drag_group_end: (d, i) ->
    if !selected_node_group
      @publishEvent 'clear_active_nodes'
      d.set({x: d3.event.sourceEvent.layerX, y: d3.event.sourceEvent.layerY})
    else
      console.log '»» Node Group selected ««'
      console.log selected_node_group
      selected_node_group.view.activate()
      #@reset_selections()
    super
 
  drag_group_start: (d, i) ->
    super

  drag_group_move: (d, i) ->
    super

  drag_group_end: (d, i) ->
    if !mediator.selected_node
      mediator.publish 'clear_active_nodes'
      d.set({x: d3.event.sourceEvent.layerX, y: d3.event.sourceEvent.layerY})
    else
      console.log '»» Node Group selected'
      console.log mediator.selected_node
    super
 
  destroy_node_group: (node_group) ->
    node_group.view.dispose()
    node_group.destroy()





