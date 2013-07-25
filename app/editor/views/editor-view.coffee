mediator = require 'mediator'
template = require 'editor/views/templates/editor'

CanvasView = require 'views/canvas-view'

ToolPointerView    = require 'editor/views/tool-pointer-view'
ToolNodeView       = require 'editor/views/tool-node-view'
ToolLinkView       = require 'editor/views/tool-link-view'
ToolAxisView       = require 'editor/views/tool-axis-view'
ToolTextView       = require 'editor/views/tool-text-view'
ToolEyedropperView = require 'editor/views/tool-eyedropper-view'

HeaderView = require 'editor/views/header-view'
DetailView = require 'editor/views/detail-view'

module.exports = class EditorView extends CanvasView
  el: '#canvas'
  template: template

  initialize: ->
    super
    console.log 'Initializing EditorView'
    #console.log @model
    
    @delegate 'click', '#tool-pointer',    @activate_pointer
    @delegate 'click', '#tool-node',       @activate_node
    @delegate 'click', '#tool-link',       @activate_link
    @delegate 'click', '#tool-line',       @activate_axis
    #@delegate 'click', '#tool-text',       @activate_text
    @delegate 'click', '#tool-eyedropper', @activate_eyedropper
    
    @delegate 'click', '#tool-download', @download_svg
    
    key 'v', 'editor', @activate_pointer
    key 'n', 'editor', @activate_node
    key 'l', 'editor', @activate_link
    key 'a', 'editor', @activate_axis
    #key 't', 'editor', @activate_text
    key 'i', 'editor', @activate_eyedropper
    key.setScope('editor')
    
    key.filter = (e) ->
      scope = key.getScope()
      tagName = (e.target || e.srcElement).tagName
      if scope is 'all' or scope is 'editor'
        console.log scope
        return !(tagName == 'INPUT' || tagName == 'SELECT' || tagName == 'TEXTAREA')
      else
        return !(tagName == 'SELECT' || tagName == 'TEXTAREA')


  render: ->
    super
    console.log 'Rendering EditorView [...]'
    mediator.stage.selectAll('g.axis').attr('visibility', 'visible')
    @subview 'header_view', new HeaderView model: mediator.canvas
    @subview 'detail_view', new DetailView
    @subview 'tool_view', @toolbar_view = null
    @activate_pointer()
    @$('button').tooltip({placement: 'right'})


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
    mediator.selected_node = null
    mediator.selected_link = null
    mediator.selected_axis = null
    @toolbar_view = new ToolNodeView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

  activate_link: =>
    @removeSubview 'tool_view'
    mediator.selected_node = null
    mediator.selected_link = null
    mediator.selected_axis = null
    @toolbar_view = new ToolLinkView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

  activate_axis: =>
    @removeSubview 'tool_view'
    mediator.selected_node = null
    mediator.selected_link = null
    mediator.selected_axis = null
    @toolbar_view = new ToolAxisView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

  activate_text: =>
    @removeSubview 'tool_view'
    mediator.selected_node = null
    mediator.selected_link = null
    mediator.selected_axis = null
    @toolbar_view = new ToolTextView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

  activate_eyedropper: =>
    @removeSubview 'tool_view'
    @toolbar_view = new ToolEyedropperView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false



  download_svg: =>
    mediator.stage.select('g.x').style('opacity', 0)
    mediator.stage.select('g.y').style('opacity', 0)
    
    mediator.publish 'refresh_zoom'
    _wrapper  = $('svg g:eq(0)')[0].getBBox()
    _elements = $('#canvas_elements')[0].getBBox()
    $('svg')
      .attr('height', _wrapper.height)
      .attr('width', _wrapper.width)
    $('svg g:eq(0)').attr('transform', => 
      if _elements.x < 0 then _x = Math.abs(_elements.x) else _x = 0
      if _elements.y < 0 then _y = Math.abs(_elements.y) else _y = 0
      #Max: 2135 x 1435
      if _wrapper.width+_x > 2135
        _scale = (2135-_x/2) / (_wrapper.width+_x)
      else
        _scale = 1
      return 'translate(' + (_x*_scale) + ',' + (_y*_scale) + ') scale(' + _scale + ')'
    )

    html = mediator.outer.node().parentNode.innerHTML
    data = "data:image/svg+xml;base64,"+ btoa(html)
    
    @print_window = window.open() #data
    @print_window.document.write(html)
    @print_window.document.title = mediator.canvas.get('title')
    @print_window.document.close()
    @print_window.focus()
    @print_window.print()
    @print_window.close()

    $('svg g:eq(0)').attr('transform', null)
    mediator.publish 'refresh_canvas'
    mediator.stage.select('g.x').transition().ease('linear').style('opacity', 1)
    mediator.stage.select('g.y').transition().ease('linear').style('opacity', 1)


