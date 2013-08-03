mediator = require 'mediator'
View = require 'views/base/view'

zoom_helpers = require '/editor/lib/zoom-helpers'

module.exports = class ToolLinkView extends View
  
  initialize: ->
    super    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-link').addClass('active')
    
    #mediator.outer.attr('cursor', 'crosshair')
    @nodes = d3.selectAll('g.nodeGroup').attr('cursor', 'crosshair')
    @links = d3.selectAll('g.linkGroup').attr('pointer-events', 'none')

    @nodes
      .call(d3.behavior.drag()
        .on('dragstart', @set_source_node)
        .on('drag', @stretch_link)
        .on('dragend', @set_target_node))
      .on('mouseover', @detect_target_node)
      .on('mouseout', @reject_target_node)

  remove: ->
    # Unbind delgated events ------
    # @$el.off 'event', '#selector'
    
    # Unbind D3 Events ------------
    @nodes
      .attr('cursor', 'default')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
      .on('mouseover', null)
      .on('mouseout', null)
    @links.attr('pointer-events', 'visibleStroke')
    @placeholder?.remove()
    
    # Unbind @el ------------------
    @setElement('')
    
    super


  set_source_node: (d,i) =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    @source_node = d
    _x = d.x
    _y = d.y
    @placeholder = mediator.vis.selectAll('g#newLink')
      .data([{}])
    @placeholder
      .enter()
      .insert('g', 'g.nodeGroup')
        .attr('id', 'ghost_link')
        .attr('opacity', .75)
    @placeholder
      .append('svg:line')
        .attr('id', 'ghost_line')
        .attr('x1', _x)
        .attr('y1', _y)
        .attr('x2', _x)
        .attr('y2', _y)
        .attr('stroke', '#e5e5e5')
        .attr('stroke-width', 7)
    @placeholder
      .append('svg:circle')
        .attr('id', 'ghost_node')
        .attr('r', 10)
        .attr('fill', '#e5e5e5')

  stretch_link: (d,i) =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = zoom_helpers.get_coordinates(e)
    @placeholder.select('#ghost_line')
      .attr('x2', coordinates.x)
      .attr('y2', coordinates.y)
    @placeholder.select('#ghost_node')
      .attr('cx', coordinates.x)
      .attr('cy', coordinates.y)

  detect_target_node: (d,i) =>
    if @source_node?
      @target_node = d unless d.id is @source_node.id

  reject_target_node: (d,i) =>
    @target_node = null

  set_target_node: (d,i) =>
    if @source_node? and @target_node?
      mediator.links.create {source: @source_node.id, target: @target_node.id}, {wait: true}
    @placeholder.remove()
