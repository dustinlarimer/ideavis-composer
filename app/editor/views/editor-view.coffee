mediator = require 'mediator'
template = require 'editor/views/templates/editor'

CanvasView = require 'views/canvas-view'

ToolPointerView = require 'editor/views/tool-pointer-view'
ToolNodeView    = require 'editor/views/tool-node-view'
ToolLinkView    = require 'editor/views/tool-link-view'
ToolTextView    = require 'editor/views/tool-text-view'

module.exports = class EditorView extends CanvasView
  el: '#canvas'
  template: template

  initialize: ->
    super
    console.log 'Initializing EditorView'
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()
    
    @delegate 'click', '#tool-pointer', @activate_pointer
    @delegate 'click', '#tool-node',    @activate_node
    @delegate 'click', '#tool-link',    @activate_link
    @delegate 'click', '#tool-text',    @activate_text

  render: ->
    super
    console.log 'Rendering EditorView [...]'
    @subview 'tool_view', @toolbar_view = null
    @activate_pointer()


  # ----------------------------------
  # KEYBOARD SHORTCUTS
  # ----------------------------------

  shortcuts:
    'shift+/' : 'help'
    'v'       : 'activate_pointer'
    'n'       : 'activate_node'
    'l'       : 'activate_link'
    't'       : 'activate_text'

  help: ->
    console.log 'Keyboard shortcuts:\n' + JSON.stringify(@shortcuts, null, 4)


  # ----------------------------------
  # TOOLBAR METHODS
  # ----------------------------------

  activate_pointer: (e) ->
    @removeSubview 'tool_view'
    @toolbar_view = new ToolPointerView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view

  activate_node: (e) ->
    @removeSubview 'tool_view'
    @toolbar_view = new ToolNodeView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view

  activate_link: (e) ->
    @removeSubview 'tool_view'
    @toolbar_view = new ToolLinkView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view

  activate_text: (e) ->
    @removeSubview 'tool_view'
    @toolbar_view = new ToolTextView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view

