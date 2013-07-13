mediator = require 'mediator'
View = require 'views/base/view'

Node = require 'models/node'

module.exports = class ToolPointerView extends View

  initialize: ->
    super
    console.log '[-- Pointer tool activated --]'
    @mode = 'pointer'
    @copied_node = undefined
    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-pointer').addClass('active')
    mediator.outer.attr('cursor', 'default')
    
    @activate()
    
    @delegate 'click', '#canvas_background', @deselect_all
    
    @subscribeEvent 'node_created', @reset
    @subscribeEvent 'node_removed', @prune_links


  remove: ->
    @$el.off 'click', '#canvas_background'
    @deactivate()
    @copied_node = undefined
    @deselect_all()
    
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
    
    d3.selectAll('g.nodeGroup')
      .call(d3.behavior.drag()
        .on('dragstart', @node_drag_start)
        .on('drag', @node_drag_move)
        .on('dragend', @node_drag_stop))
    
    d3.selectAll('g.linkGroup')
      .call(d3.behavior.drag()
        .on('dragstart', @link_drag_start)
        .on('drag', @link_drag_move)
        .on('dragend', @link_drag_stop))


  deactivate: =>
    key.unbind 'backspace', 'pointer'
    key.unbind 'delete', 'pointer'
    key.unbind 'del', 'pointer'
    key.unbind 'command+c', 'pointer'
    key.unbind 'control+c', 'pointer'
    key.unbind 'command+v', 'pointer'
    key.unbind 'control+v', 'pointer'
    key.setScope ''

    d3.selectAll('g.nodeGroup')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
    
    d3.selectAll('g.linkGroup')
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
      
    return false

  keypress_copy: =>
    console.log 'keypress_copy'
    if mediator.selected_node?
      @copied_node = mediator.selected_node
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
    return false


  # ----------------------------------
  # NODE METHODS
  # ----------------------------------

  node_drag_start: (d, i) ->
    mediator.publish 'refresh_canvas'
    mediator.publish 'clear_active'
    mediator.selected_node = d
    mediator.selected_link = null 

  node_drag_move: (d, i) ->
    mediator.selected_node = null
    d.fixed = true
    d.x = d3.event.x
    d.y = d3.event.y
    d.px = d.x
    d.py = d.y
    d.scale = d.model.get('scale') or 1
    d.rotate = d.model.get('rotate')
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ') scale(' + d.scale + ') rotate(' + d.rotate + ')')
  
  node_drag_stop: (d, i) =>
    if mediator.selected_node is null
      d.model.save x: d.x, y: d.y
    else
      d.view.activate()
      mediator.publish 'activate_detail', d.model

  destroy_node_group: (node_group) ->
    node_group.view.dispose()
    node_group.model.destroy()


  # ----------------------------------
  # LINK METHODS
  # ----------------------------------

  link_drag_start: (d,i) ->
    mediator.publish 'refresh_canvas'
    mediator.publish 'clear_active'
    mediator.selected_link = d
    mediator.selected_node = null

  link_drag_move: (d,i) ->
    mediator.selected_link = null

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
  # MISC METHODS
  # ----------------------------------

  deselect_all: ->
    mediator.selected_node = null
    mediator.selected_link = null

    mediator.publish 'deactivate_detail'
    mediator.publish 'clear_active'
