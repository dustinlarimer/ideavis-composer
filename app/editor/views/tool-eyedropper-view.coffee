mediator = require 'mediator'
View = require 'views/base/view'

Node = require 'models/node'
Path = require 'models/path'
Text = require 'models/text'

module.exports = class ToolEyedropperView extends View

  initialize: ->
    super
    console.log '[-- Eyedropper tool activated --]'
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-eyedropper').addClass('active')
    
    @nodes = d3.selectAll('g.nodeGroup')
    @links = d3.selectAll('g.linkGroup')
    @axes = d3.selectAll('g.axisGroup')
    @activate()

  remove: ->
    @deactivate()
    
    @nodes = null
    @links = null
    @axes = null
    
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
    
    if mediator.selected_axis?
      @axes.attr('cursor', 'crosshair')
    else
      @axes.attr('cursor', 'pointer')

    @nodes
      .call(d3.behavior.drag()
        .on('dragstart', @node_drag_start)
        .on('dragend', @node_drag_stop))
    
    @links
      .call(d3.behavior.drag()
        .on('dragstart', @link_drag_start)
        .on('dragend', @link_drag_stop))

    @axes
      .call(d3.behavior.drag()
        .on('dragstart', @axis_drag_start)
        .on('dragend', @axis_drag_stop))

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
    @axes
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
    @axes.attr('cursor', 'pointer')

    if mediator.selected_node and mediator.selected_node.id isnt d.id
      _target_attributes = _.pick(d.model.toJSON(), 'opacity', 'rotate')
      _target_paths = []
      _.each(_.where(d.model.toJSON().nested, {type: 'path'}), (d,i)=>
        _target_paths.push d
      )
      _target_texts = []
      _.each(_.where(d.model.toJSON().nested, {type: 'text'}), (d,i)=>
        _target_texts.push _.omit(d, 'text')
      )
      _original_texts = _.where(mediator.selected_node.model.get('nested'), {type: 'text'})
      _.each(_original_texts, (d,i)=>
        _target_texts[i]?.text = d.text or ''
      )
      _model=
        opacity: _target_attributes.opacity
        rotate:  _target_attributes.rotate
        nested:  _.union(_target_paths, _target_texts)
      mediator.selected_node.model.save _model
      mediator.selected_node.model.build_nested()
      mediator.selected_node.view.rebuild()

    else
      mediator.selected_node = d
      mediator.selected_link = null
      mediator.selected_axis = null
      mediator.publish 'clear_active'
      d.view.activate()
    
    mediator.publish 'activate_detail', mediator.selected_node.model
    @nodes.attr('cursor', 'crosshair')
  
  node_drag_stop: (d, i) =>
    return false
    #console.log 'node_drag_stop'



  # ----------------------------------
  # LINK METHODS
  # ----------------------------------

  link_drag_start: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    @nodes.attr('cursor', 'pointer')
    @links.attr('cursor', 'default')
    @axes.attr('cursor', 'pointer')
    #mediator.selected_node = null

    if mediator.selected_link and mediator.selected_link.id isnt d.id
      _model = _.omit(d.model.toJSON(), '__v', '_id', 'composition_id', 'endpoints', 'midpoints', 'markers', 'source', 'target', 'label_text')
      mediator.selected_link.model.save _model
      mediator.selected_link.model.build_markers()
    else
      mediator.selected_node = null
      mediator.selected_link = d
      mediator.selected_axis = null
      mediator.publish 'clear_active'
      #d.view.activate()

    mediator.publish 'activate_detail', mediator.selected_link.model
    @links.attr('cursor', 'crosshair')

  link_drag_stop: (d,i) =>
    console.log 'link_drag_stop'



  # ----------------------------------
  # AXIS METHODS
  # ----------------------------------

  axis_drag_start: (d, i) =>
    d3.event.sourceEvent.stopPropagation()
    @nodes.attr('cursor', 'pointer')
    @links.attr('cursor', 'pointer')
    @axes.attr('cursor', 'default')
    
    if mediator.selected_axis and mediator.selected_axis.id isnt d.id
      _model = _.omit(d.attributes, 'label_text', 'rotate', 'x', 'y', 'endpoints', 'composition_id', '_id', '__v')
      #_label = _.where(mediator.selected_axis.model.get('nested'), {type: 'text'})[0].text
      #_.where(_model.nested, {type:'text'})[0].text = _label
      mediator.selected_axis.save _model
      #mediator.selected_axis.model.build_nested()
    else
      mediator.selected_node = null
      mediator.selected_link = null
      mediator.selected_axis = d
      mediator.publish 'clear_active'
      d.view.activate()
    
    mediator.publish 'activate_detail', mediator.selected_axis.model
    @nodes.attr('cursor', 'crosshair')
  
  axis_drag_stop: (d, i) =>
    console.log 'axis_drag_stop'




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
