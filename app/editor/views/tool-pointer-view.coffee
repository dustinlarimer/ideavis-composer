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
      .on('dblclick', @node_detail_view)
    
    d3.selectAll('g.linkGroup')
      .call(d3.behavior.drag()
        .on('dragstart', @link_drag_start)
        .on('drag', @link_drag_move)
        .on('dragend', @link_drag_stop))
      .on('dblclick', @link_detail_view)

    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

    @subscribeEvent 'node_removed', @prune_links

  remove: ->
    # Unbind delgated events ------
    # @$el.off 'event', '#selector'
    
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
    console.log 'Delete!'
    if mediator.selected_node?
      @destroy_node_group(mediator.selected_node)
      mediator.selected_node = null
    if mediator.selected_link?
      @destroy_link_group(mediator.selected_link)
      mediator.selected_link = null
    e.preventDefault()


  # ----------------------------------
  # NODE METHODS
  # ----------------------------------

  node_drag_start: (d, i) ->
    console.log 'pointer:node_drag_start'
    mediator.selected_node = d
    mediator.publish 'clear_active_nodes'
    d3.select(@).classed 'active', true
    
    #polymorphize this shit
    mediator.selected_link = null
    mediator.publish 'clear_active_links'

  node_drag_move: (d, i) ->
    console.log 'pointer:node_drag_move'
    d.x = d3.event.x
    d.y = d3.event.y
    d.px = d.x
    d.py = d.y
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ')')
  
  node_drag_stop: (d, i) ->
    console.log 'pointer:node_drag_stop'
    d.model.set({x: d3.event.sourceEvent.layerX, y: d3.event.sourceEvent.layerY})

  node_detail_view: (d) ->
    console.log '[trigger node detail view]'

  destroy_node_group: (node_group) ->
    node_group.view.dispose()
    node_group.model.destroy()


  # ----------------------------------
  # LINK METHODS
  # ----------------------------------

  link_drag_start: (d,i) ->
    console.log 'pointer:link_drag_start'
    mediator.selected_link = d
    mediator.publish 'clear_active_links'
    d3.select(@).classed 'active', true
    
    #polymorphize this shit
    mediator.selected_node = null
    mediator.publish 'clear_active_nodes'

  link_drag_move: (d,i) ->
    console.log 'pointer:link_drag_move'

  link_drag_stop: (d,i) ->
    console.log 'pointer:link_drag_stop'

  link_detail_view: (d) ->
    console.log '[trigger link detail view]'

  prune_links: (dead_node) ->
    d3.selectAll('g.linkGroup').each((d,i) => 
      if d.source.id is dead_node.id or d.target.id is dead_node.id
        @destroy_link_group(d)
    )

  destroy_link_group: (link_group) ->
    link_group.view.dispose()
    link_group.model.destroy()

