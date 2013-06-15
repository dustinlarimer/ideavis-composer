mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/editor'

CanvasView = require 'views/canvas-view'

Link = require 'models/link'

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
    @delegate 'click', '#tool-link',    @activate_link
    @delegate 'click', '#tool-text',    @activate_text

    @delegate 'mousedown', 'svg', @mousedown
    @delegate 'mousemove', 'svg', @mousemove
    @delegate 'mouseup', 'svg', @mouseup
    
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

    @subscribeEvent 'node_removed', @prune_links

  render: ->
    super
    console.log 'Rendering EditorView [...]'



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
    #console.log 'Keyboard shortcuts enabled'
    #mediator.links.create {source: mediator.nodes.models[0].id, target: mediator.nodes.models[1].id}
    #test_link = new Link {source: mediator.nodes.models[0].id, target: mediator.nodes.models[1].id}
    #mediator.links.push test_link
    console.log mediator.links

  help: ->
    console.log 'Keyboard shortcuts:\n' + JSON.stringify(@shortcuts, null, 4)

  keydown: ->
    #console.log 'Keycode ' + d3.event.keyCode + ' pressed'
    key_selection = d3.event.keyCode
    switch d3.event.keyCode
      when 8, 46
        console.log '[del]'
        d3.event.preventDefault() if d3.event
        if mediator.selected_node
          @destroy_node_group(mediator.selected_node)
          mediator.selected_node = null
        break
      when 32
        d3.event.preventDefault() if d3.event
        break
      when 91
        console.log '[cmnd]'
        break

  keyup: ->
    key_selection = null



  # ----------------------------------
  # MOUSE METHODS
  # ----------------------------------

  mousedown: (e) ->
    console.log '!» mousedown'

  mousemove: (e) ->
    #console.log '!» mousemove'
  
  mouseup: (e) ->
    console.log '!» mouseup'
    if e.target.tagName is 'svg' or 'rect'
      switch toolbar_mode
        when 'pointer'
          break
        when 'node'
          mediator.nodes.create x: e.offsetX, y: e.offsetY
          break
        when 'link'
          console.log '{{ mediator.links.create }}'
          console.log mediator.selected_node if mediator.selected_node?
          break
        when 'text'
          console.log '{{ mediator.texts.create }}'
          break



  # ----------------------------------
  # TOOLBAR METHODS
  # ----------------------------------

  toolbar_mode = 'pointer'

  clear_tool_selection: ->
    $('#toolbar button.active').removeClass('active')

  activate_pointer: (e) ->
    console.log 'Pointer tool active'
    if e.type is 'keydown'
      @clear_tool_selection()
      $('#toolbar button#tool-pointer').addClass('active')
    toolbar_mode = 'pointer'
    mediator.outer.attr('cursor', 'default')

  activate_node: (e) ->
    console.log 'Node tool activated'
    if e.type is 'keydown'
      @clear_tool_selection()
      $('#toolbar button#tool-node').addClass('active')
    toolbar_mode = 'node'
    mediator.outer.attr('cursor', 'crosshair')

  activate_link: (e) ->
    console.log 'Link tool active'
    if e.type is 'keydown'
      @clear_tool_selection()
      $('#toolbar button#tool-link').addClass('active')
    toolbar_mode = 'link'
    mediator.outer.attr('cursor', 'crosshair')

  activate_text: (e) ->
    console.log 'Text tool active'
    if e.type is 'keydown'
      @clear_tool_selection()
      $('#toolbar button#tool-text').addClass('active')
    toolbar_mode = 'text'
    mediator.outer.attr('cursor', 'crosshair')



  # ----------------------------------
  # NODE GROUP METHODS (OVERRIDE)
  # ----------------------------------
 
  drag_group_start: (d, i) ->
    if mediator.selected_node?
      if toolbar_mode is 'link'
        _source = mediator.selected_node
        _target = d
        unless _target.model.id is _source.model.id
          mediator.links.create {source: _source.model.id, target: _target.model.id}
          #d = _source
    super

  drag_group_move: (d, i) ->
    super

  drag_group_end: (d, i) ->
    if !mediator.selected_node
      mediator.publish 'clear_active_nodes'
      d.model.set({x: d3.event.sourceEvent.layerX, y: d3.event.sourceEvent.layerY})
    else
      console.log '»» Node Group selected'
      console.log mediator.selected_node
    super
 
  destroy_node_group: (node_group) ->
    node_group.view.dispose()
    node_group.model.destroy()

  prune_links: (dead_node) ->
    d3.selectAll('g.linkGroup').each((d,i) => 
      if d.source.id is dead_node.id or d.target.id is dead_node.id
        @destroy_link_group(d)
    )

  destroy_link_group: (link_group) ->
    link_group.view.dispose()
    link_group.model.destroy()

