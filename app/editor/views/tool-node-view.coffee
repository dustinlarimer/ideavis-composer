mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ToolNodeView extends View
  
  initialize: ->
    super
    console.log 'Initializing ToolNodeView'    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-node').addClass('active')
    
    mediator.outer.attr('cursor', 'crosshair')
    d3.select('#canvas_elements_background')
      .call(d3.behavior.drag()
        .on('dragend', @create_node))

    @subscribeEvent 'node_created', @activate
    @activate()

  activate: =>
    @nodes = d3.selectAll('g.nodeGroup').attr('pointer-events', 'none')
    @links = d3.selectAll('g.linkGroup').attr('pointer-events', 'none')

  remove: ->
    mediator.outer.attr('cursor', 'default')
    d3.select('#canvas_elements_background')
      .call(d3.behavior.drag()
        .on('dragend', null))
    
    @nodes.attr('pointer-events', 'all')
    @links.attr('pointer-events', 'visibleStroke')
    @nodes = null
    @links = null
    # Unbind @el ------------------
    @setElement('')
    super

  create_node: =>
    d3.event.sourceEvent.stopPropagation()
    e = d3.event.sourceEvent
    
    _offset = $('#canvas_elements')[0].getBBox()
    _parent = $('#canvas_elements')[0].getBoundingClientRect()
    _x = null
    _y = null
    _scale = mediator.offset[1] or 1
    
    #_parent.left-50 == _offset.x
    #_parent.top-50  == _offset.y

    if _parent.left > 50
      _x = (_offset.x*_scale) - (_parent.left-50) + (e.clientX-50)
      #_x = (e.clientX-50) - (_parent.left-50) + Math.abs(_offset.x*_scale)
    else
      _x = Math.abs(_parent.left-50) + (e.clientX-50) - Math.abs(_offset.x*_scale)
    
    if _parent.top > 50
      _y = (_offset.y*_scale) - (_parent.top-50) + (e.clientY-50)
      #_y = (e.clientY-50) - (_parent.top-50) + Math.abs(_offset.y*_scale)
    else
      _y = Math.abs(_parent.top-50) + (e.clientY-50) - Math.abs(_offset.y*_scale)
    
    point=
      x: _x / _scale
      y: _y / _scale


    mediator.nodes.create {x: point.x, y: point.y}, {wait: true}
    #mediator.nodes.create {x: e.pageX-50, y: e.pageY-50}, {wait: true}
