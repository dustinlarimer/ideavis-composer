mediator = require 'mediator'
View = require 'views/base/view'

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
    mediator.zoom = false
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
    #console.log 'stretch_link'
    @placeholder.select('#ghost_line')
      .attr('x2', d3.event.x)
      .attr('y2', d3.event.y)
    @placeholder.select('#ghost_node')
      .attr('cx', d3.event.x)
      .attr('cy', d3.event.y)

  detect_target_node: (d,i) =>
    #console.log 'detect_target_node'
    if @source_node?
      @target_node = d unless d.id is @source_node.id
      #console.log @target_node

  reject_target_node: (d,i) =>
    #console.log 'reject_target_node'
    @target_node = null

  set_target_node: (d,i) =>
    #console.log 'set_target_node'
    if @source_node? and @target_node?
      mediator.links.create {source: @source_node.id, target: @target_node.id}, {wait: true}
    @placeholder.remove()
    mediator.zoom = true
