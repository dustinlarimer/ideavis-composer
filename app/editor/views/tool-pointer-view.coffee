mediator = require 'mediator'
View = require 'views/base/view'
Node = require 'models/node'
zoom_helpers = require '/editor/lib/zoom-helpers'

module.exports = class ToolPointerView extends View

  initialize: ->
    super
    console.log '[-- Pointer tool activated --]'
    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-pointer').addClass('active')

    @snap = 25

    @nodes = null
    @links = null
    @axes = null
    
    @node_motion = null
    @link_motion = null
    @axis_motion = null
    
    @copied_node = undefined
    @copied_axis = undefined
    
    @activate()
    
    @delegate 'click', '#canvas_elements_background', @deselect_all
    
    @subscribeEvent 'node_created', @reset
    @subscribeEvent 'node_removed', @prune_links
    @subscribeEvent 'axis_created', @reset

  remove: ->
    @$el.off 'click', '#canvas_elements_background'
    @deactivate()
    
    @nodes = null
    @links = null
    @axes = null
    
    @copied_node = undefined
    @copied_axis = undefined

    @node_range = null
    
    #mediator.publish 'clear_active'
    @setElement('')
    super


  activate: =>
    key 'backspace', 'editor', @keypress_delete
    key 'delete', 'editor', @keypress_delete
    key 'del', 'editor', @keypress_delete
    key 'command+c', 'editor', @keypress_copy
    key 'control+c', 'editor', @keypress_copy
    key 'command+v', 'editor', @keypress_paste
    key 'control+v', 'editor', @keypress_paste
    #key.setScope('editor')

    @controls = mediator.controls.append('svg:g').attr('id', 'pointer_controls')

    @node_range=
      x: _.map(mediator.nodes.models, (node, index)=> node.get('x'))
      y: _.map(mediator.nodes.models, (node, index)=> node.get('y'))

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
        #.on('drag', @link_drag_move)
        .on('dragend', @link_drag_stop))

    @axes = d3.selectAll('g.axisGroup')
      .attr('cursor', 'pointer')
      .call(d3.behavior.drag()
        .on('dragstart', @axis_drag_start)
        .on('drag', @axis_drag_move)
        .on('dragend', @axis_drag_end))


  deactivate: =>
    key.unbind 'backspace', 'editor'
    key.unbind 'delete', 'editor'
    key.unbind 'del', 'editor'
    key.unbind 'command+c', 'editor'
    key.unbind 'control+c', 'editor'
    key.unbind 'command+v', 'editor'
    key.unbind 'control+v', 'editor'
    #key.setScope('')

    @controls?.remove()

    @mousedown_offset = null
    @active_node_target = null
    @node_motion = null
    @link_motion = null
    @axis_motion = null

    @node_range = null

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
        #.on('drag', null)
        .on('dragend', null))

    @axes = d3.selectAll('g.axisGroup')
      .attr('cursor', 'default')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))


  reset: =>
    # Ensure keybindings for Copy, Paste, Delete
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
      @deselect_all()
    if mediator.selected_link?
      if mediator.selected_link.view.selected_midpoint?
        mediator.selected_link.view.destroy_midpoint()
      else
        @destroy_link_group(mediator.selected_link)
        mediator.selected_link = null
        @deselect_all()
    if mediator.selected_axis?
      @destroy_axis_group(mediator.selected_axis)
      mediator.selected_axis = null
      @deselect_all()
    return false

  keypress_copy: =>
    console.log 'keypress_copy'
    @copied_node = null
    @copied_axis = null
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

  node_drag_start: (d, i) =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = zoom_helpers.get_coordinates(e)

    mediator.publish 'refresh_canvas' #'pause_canvas'    
    @active_node_target = d3.select(d3.event.sourceEvent.target.parentElement).data()[0]
    if mediator.selected_node?.id is d.id
      d.view.deactivate()
    else
      mediator.publish 'clear_active'
    mediator.selected_node = d
    mediator.selected_link = null
    mediator.selected_axis = null

    @mousedown_offset=
      x: (d.x - coordinates.x)
      y: (d.y - coordinates.y)

  node_drag_move: (d, i) =>
    d3.event.sourceEvent.stopPropagation()
    @node_motion = true
    rel_x = d3.event.x + @mousedown_offset.x
    rel_y = d3.event.y + @mousedown_offset.y
    if key.shift
      d.x = Math.round(rel_x / @snap) * @snap
      d.y = Math.round(rel_y / @snap) * @snap
    else
      d.x = Math.round(rel_x)
      d.y = Math.round(rel_y) 

      _.each(@node_range.x, (x, j)=>
        if d.x > (x-7) and d.x < (x+7)
          d.x = x
      )
      _.each(@node_range.y, (y, j)=>
        if d.y > (y-7) and d.y < (y+7)
          d.y = y
      )

    d.px = d.x
    d.py = d.y
    d.scale = d.model.get('scale') or 1
    d.rotate = d.model.get('rotate')
    d3.select(@nodes[0][i]).attr('transform', 'translate('+ d.x + ',' + d.y + ') rotate(' + d.rotate + ')')
  
  node_drag_stop: (d, i) =>
    if @node_motion
      d.model.save x: d.x, y: d.y
      d.view.activate()
    else
      if key.shift
        _check = _.where(mediator.selected_nodes, {id: d.id})
        if _check.length > 0
          mediator.selected_nodes = _.reject(mediator.selected_nodes, {id: d.id})
          d.view.deactivate()
        else
          mediator.selected_nodes.push(d)
          d.view.activate(@active_node_target)
        console.log mediator.selected_nodes
      else
        d.view.activate(@active_node_target)

    @reset()
    mediator.publish 'activate_detail', d.model
    #mediator.publish 'refresh_canvas'

  destroy_node_group: (node_group) ->
    node_group.view.dispose()
    node_group.model.destroy()


  # ----------------------------------
  # LINK METHODS
  # ----------------------------------

  link_drag_start: (d,i) ->
    d3.event.sourceEvent.stopPropagation()
    mediator.publish 'refresh_canvas'
    mediator.publish 'clear_active'
    mediator.selected_link = d
    mediator.selected_node = null
    mediator.selected_axis = null

  #link_drag_move: (d,i) ->
  #  d3.event.sourceEvent.stopPropagation()
  #  mediator.selected_link = null

  link_drag_stop: (d,i) ->
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

  axis_drag_start: (d, i) =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = zoom_helpers.get_coordinates(e)
    
    mediator.publish 'refresh_canvas'
    mediator.publish 'clear_active'
    mediator.selected_axis = d
    mediator.selected_node = null
    mediator.selected_link = null

    @mousedown_offset=
      x: (d.get('x') - coordinates.x)
      y: (d.get('y') - coordinates.y)

  axis_drag_move: (d, i) =>
    d3.event.sourceEvent.stopPropagation()
    @axis_motion = true
    rel_x = d3.event.x + @mousedown_offset.x
    rel_y = d3.event.y + @mousedown_offset.y
    if key.shift
      d.x = Math.round(rel_x / @snap) * @snap
      d.y = Math.round(rel_y / @snap) * @snap
    else
      d.x = Math.round(rel_x)
      d.y = Math.round(rel_y)
    d.rotate = d.get('rotate')
    d3.select(@axes[0][i]).attr('transform', 'translate('+ d.x + ',' + d.y + ') rotate(' + d.rotate + ')')

  axis_drag_end: (d, i) =>
    if @axis_motion
      d.save x: d.x, y: d.y
    @reset()
    d.view.activate()
    mediator.publish 'activate_detail', d

  destroy_axis_group: (axis_group) ->
    axis_group.view.dispose()
    axis_group.destroy()


  # ----------------------------------
  # MISC METHODS
  # ----------------------------------

  deselect_all: ->

    # Experimental
    mediator.selected_nodes = []

    mediator.selected_node = null
    mediator.selected_link = null
    mediator.selected_axis = null

    mediator.publish 'deactivate_detail'
    mediator.publish 'clear_active'
    mediator.publish 'refresh_canvas'
