mediator = require 'mediator'
View = require 'views/base/view'

Node = require 'models/node'

module.exports = class ToolPointerView extends View

  initialize: ->
    super
    console.log '[-- Pointer tool activated --]'
    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-pointer').addClass('active')

    @nodes = null
    @links = null
    @axes = null
    @copied_node = undefined
    @copied_axis = undefined
    
    @activate()
    
    @delegate 'click', '#canvas_elements_background', @deselect_all
    
    @subscribeEvent 'node_created', @reset
    @subscribeEvent 'node_removed', @prune_links


  remove: ->
    @$el.off 'click', '#canvas_elements_background'
    @deactivate()
    @nodes = null
    @links = null
    @axes = null
    @copied_node = undefined
    @copied_axis = undefined
    #@deselect_all()
    @setElement('')
    super


  activate: =>
    key 'backspace', 'pointer', @keypress_delete
    key 'delete', 'pointer', @keypress_delete
    key 'del', 'pointer', @keypress_delete
    key 'command+c', 'pointer', @keypress_copy
    key 'control+c', 'pointer', @keypress_copy
    key 'command+v', 'pointer', @keypress_paste
    key 'control+v', 'pointer', @keypress_paste
    key.setScope 'pointer'
    key.filter = (e) ->
      tagName = (e.target || e.srcElement).tagName
      return !(tagName == 'INPUT' || tagName == 'SELECT' || tagName == 'TEXTAREA')

    @nodes = d3.selectAll('g.nodeGroup')
      .attr('cursor', 'pointer')
      .call(d3.behavior.drag()
        .on('dragstart', @node_drag_start)
        .on('drag', @node_drag_move)
        .on('dragend', @node_drag_stop))
    
    @links = d3.selectAll('g.linkGroup')
      .attr('cursor', 'pointer')
      .call(d3.behavior.drag()
        .on('dragstart', @link_drag_start)
        .on('drag', @link_drag_move)
        .on('dragend', @link_drag_stop))

    @axes = d3.selectAll('g.axisGroup')
      .attr('cursor', 'pointer')
      .call(d3.behavior.drag()
        .on('dragstart', @axis_drag_start)
        .on('drag', @axis_drag_move)
        .on('dragend', @axis_drag_end))

  deactivate: =>
    key.unbind 'backspace', 'pointer'
    key.unbind 'delete', 'pointer'
    key.unbind 'del', 'pointer'
    key.unbind 'command+c', 'pointer'
    key.unbind 'control+c', 'pointer'
    key.unbind 'command+v', 'pointer'
    key.unbind 'control+v', 'pointer'
    key.setScope ''

    @nodes
      .attr('cursor', 'default')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
    
    @links
      .attr('cursor', 'default')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))

  reset: =>
    @deactivate()
    @activate()


  # ----------------------------------
  # KEYBOARD SHORTCUTS
  # ----------------------------------

  keypress_delete: =>
    console.log 'keypress_delete'
    if mediator.selected_node?
      @destroy_node_group(mediator.selected_node)
      mediator.selected_node = null
    if mediator.selected_link?
      #console.log mediator.selected_link.view.selected_midpoint
      if mediator.selected_link.view.selected_midpoint?
        mediator.selected_link.view.destroy_midpoint()
      else
        @destroy_link_group(mediator.selected_link)
        mediator.selected_link = null
    if mediator.selected_axis?
      @destroy_axis_group(mediator.selected_axis)
      mediator.selected_axis = null
    return false

  keypress_copy: =>
    console.log 'keypress_copy'
    if mediator.selected_node?
      @copied_node = mediator.selected_node
    if mediator.selected_axis?
      @copied_axis = mediator.selected_axis
    return false

  keypress_paste: =>
    console.log 'keypress_paste'
    if @copied_node?
      clone = @copied_node.model.toJSON()
      clone._id = undefined
      clone.__v = undefined
      clone.x = clone.x + 25
      clone.y = clone.y + 25
      mediator.nodes.create clone, {wait: true}
    if @copied_axis?
      clone = @copied_axis.toJSON()
      clone._id = undefined
      clone.__v = undefined
      clone.x = clone.x + 25
      clone.y = clone.y + 25
      mediator.axes.create clone, {wait: true}
    return false


  # ----------------------------------
  # NODE METHODS
  # ----------------------------------

  node_drag_start: (d, i) ->
    mediator.zoom = false
    mediator.publish 'refresh_canvas'
    mediator.publish 'clear_active'
    mediator.selected_node = d
    mediator.selected_link = null
    mediator.selected_axis = null

  node_drag_move: (d, i) ->
    mediator.zoom = false
    mediator.selected_node = null
    d.fixed = true
    d.x = d3.event.x
    d.y = d3.event.y
    d.px = d.x
    d.py = d.y
    d.scale = d.model.get('scale') or 1
    d.rotate = d.model.get('rotate')
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ') rotate(' + d.rotate + ')')
  
  node_drag_stop: (d, i) =>
    mediator.zoom = true
    if mediator.selected_node is null
      d.model.save x: d.x, y: d.y
    else
      @reset() # Ensure keybindings for Copy, Paste, Delete
      d.view.activate()
      mediator.publish 'activate_detail', d.model

  destroy_node_group: (node_group) ->
    node_group.view.dispose()
    node_group.model.destroy()


  # ----------------------------------
  # LINK METHODS
  # ----------------------------------

  link_drag_start: (d,i) ->
    mediator.zoom = false
    mediator.publish 'refresh_canvas'
    mediator.publish 'clear_active'
    mediator.selected_link = d
    mediator.selected_node = null
    mediator.selected_axis = null

  link_drag_move: (d,i) ->
    mediator.selected_link = null

  link_drag_stop: (d,i) ->
    mediator.zoom = true
    if mediator.selected_link?
      d.view.activate()
      mediator.publish 'activate_detail', d.model

  prune_links: (node_id) ->
    d3.selectAll('g.linkGroup').each((d,i) => 
      if d.source.id is node_id or d.target.id is node_id
        @destroy_link_group(d)
    )

  destroy_link_group: (link_group) ->
    link_group.view.dispose()
    link_group.model.destroy()


  # ----------------------------------
  # AXIS METHODS
  # ----------------------------------

  axis_drag_start: (d, i) ->
    mediator.zoom = false
    mediator.publish 'refresh_canvas'
    mediator.publish 'clear_active'    
    mediator.selected_axis = d
    mediator.selected_node = null
    mediator.selected_link = null

  axis_drag_move: (d, i) ->
    mediator.zoom = false
    mediator.selected_axis = null
    d.x = d3.event.x
    d.y = d3.event.y
    d.rotate = d.get('rotate')
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ') rotate(' + d.rotate + ')')

  axis_drag_end: (d, i) =>
    mediator.zoom = true
    if mediator.selected_axis is null
      d.save x: d.x, y: d.y
    else
      @reset()
      d.view.activate()
      #mediator.publish 'activate_detail', d.model

  destroy_axis_group: (axis_group) ->
    axis_group.view.dispose()
    axis_group.destroy()


  # ----------------------------------
  # MISC METHODS
  # ----------------------------------

  deselect_all: (e) ->
    #console.log $(e.target)[0]
    mediator.selected_node = null
    mediator.selected_link = null
    mediator.selected_axis = null

    mediator.publish 'deactivate_detail'
    mediator.publish 'clear_active'
