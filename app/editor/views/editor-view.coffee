mediator = require 'mediator'
template = require 'editor/views/templates/editor'

CanvasView = require 'views/canvas-view'

ToolPointerView = require 'editor/views/tool-pointer-view'
ToolNodeView    = require 'editor/views/tool-node-view'
ToolLinkView    = require 'editor/views/tool-link-view'
ToolTextView    = require 'editor/views/tool-text-view'

HeaderView = require 'editor/views/header-view'
DetailView = require 'editor/views/detail-view'

module.exports = class EditorView extends CanvasView
  el: '#canvas'
  template: template

  initialize: ->
    super
    console.log 'Initializing EditorView'
    
    @delegate 'click', '#tool-pointer', @activate_pointer
    @delegate 'click', '#tool-node',    @activate_node
    @delegate 'click', '#tool-link',    @activate_link
    @delegate 'click', '#tool-text',    @activate_text
    
    key 'v', @activate_pointer
    key 'n', @activate_node
    key 'l', @activate_link
    key 't', @activate_text

  render: ->
    super
    console.log 'Rendering EditorView [...]'
    @subview 'header_view', new HeaderView model: mediator.canvas
    @subview 'detail_view', new DetailView
    @subview 'tool_view', @toolbar_view = null
    @activate_pointer()


  # ----------------------------------
  # TOOLBAR METHODS
  # ----------------------------------

  activate_pointer: =>
    @removeSubview 'tool_view'
    @toolbar_view = new ToolPointerView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

  activate_node: =>
    @removeSubview 'tool_view'
    @toolbar_view = new ToolNodeView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

  activate_link: =>
    @removeSubview 'tool_view'
    @toolbar_view = new ToolLinkView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

  activate_text: =>
    @removeSubview 'tool_view'
    @toolbar_view = new ToolTextView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

