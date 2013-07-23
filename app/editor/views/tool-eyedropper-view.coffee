mediator = require 'mediator'
View = require 'views/base/view'

Node = require 'models/node'

module.exports = class ToolEyedropperView extends View

  initialize: ->
    super
    console.log '[-- Eyedropper tool activated --]'
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-eyedropper').addClass('active')
    
    @nodes = d3.selectAll('g.nodeGroup')
    @links = d3.selectAll('g.linkGroup')
    @activate()

  remove: ->
    @deactivate()
    @setElement('')
    super

  activate: =>
    
    if mediator.selected_node?
      @nodes.attr('cursor', 'crosshair')
    else
      @nodes.attr('cursor', 'pointer')
    
    if mediator.selected_link?
      @links.attr('cursor', 'crosshair')
    else
      @links.attr('cursor', 'pointer')
    
    @nodes
      .call(d3.behavior.drag()
        .on('dragstart', @node_drag_start)
        .on('dragend', @node_drag_stop))
    
    @links
      .call(d3.behavior.drag()
        .on('dragstart', @link_drag_start)
        .on('dragend', @link_drag_stop))

  deactivate: =>
    @nodes
      .attr('cursor', 'default')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('dragend', null))
    @links
      .attr('cursor', 'default')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('dragend', null))


  # ----------------------------------
  # NODE METHODS
  # ----------------------------------

  node_drag_start: (d, i) =>
    d3.event.sourceEvent.stopPropagation()
    @nodes.attr('cursor', 'default')
    @links.attr('cursor', 'pointer')
    
    if mediator.selected_node and mediator.selected_node.id isnt d.id
      _model = _.pick(d.model.toJSON(), 'opacity', 'rotate', 'nested')
      _label = _.where(mediator.selected_node.model.get('nested'), {type: 'text'})[0].text
      _.where(_model.nested, {type:'text'})[0].text = _label
      mediator.selected_node.model.save _model
      mediator.selected_node.model.build_nested()
    else
      mediator.selected_link = null
      mediator.selected_node = d
      mediator.publish 'clear_active'
      d.view.activate()
    
    mediator.publish 'activate_detail', mediator.selected_node.model
    @nodes.attr('cursor', 'crosshair')
  
  node_drag_stop: (d, i) =>
    console.log 'node_drag_stop'



  # ----------------------------------
  # LINK METHODS
  # ----------------------------------

  link_drag_start: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    @nodes.attr('cursor', 'pointer')
    @links.attr('cursor', 'default')
    #mediator.selected_node = null

    if mediator.selected_link and mediator.selected_link.id isnt d.id
      _model = _.omit(d.model.toJSON(), '__v', '_id', 'composition_id', 'endpoints', 'midpoints', 'markers', 'source', 'target', 'label_text')
      mediator.selected_link.model.save _model
      mediator.selected_link.model.build_markers()
    else
      mediator.selected_node = null
      mediator.selected_link = d
      mediator.publish 'clear_active'
      d.view.activate()

    mediator.publish 'activate_detail', mediator.selected_link.model
    @links.attr('cursor', 'crosshair')

  link_drag_stop: (d,i) =>
    console.log 'link_drag_stop'


  # ----------------------------------
  # MISC METHODS
  # ----------------------------------

  deselect_all: (e) ->
    #console.log $(e.target)[0]
    mediator.selected_node = null
    mediator.selected_link = null

    mediator.publish 'deactivate_detail'
    mediator.publish 'clear_active'
    mediator.publish 'refresh_canvas'
