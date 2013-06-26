mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ToolPointerView extends View

  initialize: ->
    super
    console.log '[-- Pointer tool activated --]'
    @mode = 'pointer'
    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-pointer').addClass('active')
    mediator.outer.attr('cursor', 'default')
    
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
    
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()
    
    @delegate 'click', '#canvas_background', @deselect_all
    
    @subscribeEvent 'node_removed', @prune_links

  remove: ->
    # Unbind delgated events ------
    @$el.off 'click', '#canvas_background'
    
    # Unbind D3 Events ------------
    d3.selectAll('g.nodeGroup')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
      .on('dblclick', null)
    
    d3.selectAll('g.linkGroup')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
    
    # Unbind @el ------------------
    @setElement('')
    
    console.log '[xx Pointer tool out! xx]'
    super


  # ----------------------------------
  # KEYBOARD SHORTCUTS
  # ----------------------------------

  shortcuts:
    'backspace' : 'keypress_delete'
    'delete'    : 'keypress_delete'
    'del'       : 'keypress_delete'

  keypress_delete: (e) ->
    e.preventDefault()
    if mediator.selected_node?
      @destroy_node_group(mediator.selected_node)
      mediator.selected_node = null
    if mediator.selected_link?
      @destroy_link_group(mediator.selected_link)
      mediator.selected_link = null


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
  
  node_drag_stop: (d, i) ->
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
    console.log 'pointer:link_drag_start'
    mediator.publish 'refresh_canvas'
    mediator.publish 'clear_active'
    mediator.selected_link = d
    mediator.selected_node = null

  link_drag_move: (d,i) ->
    console.log 'pointer:link_drag_move'
    mediator.selected_link = null

  link_drag_stop: (d,i) ->
    console.log 'pointer:link_drag_stop'
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
