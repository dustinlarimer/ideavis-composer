mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class NodeView extends View
  autoRender: true
  
  initialize: (data={}) ->
    @paths = @model.paths.models
    @texts = @model.texts.models
    @subscribeEvent 'clear_active_nodes', @deactivate

  deactivate: ->
    d3.select(@el).classed 'active', false

  render: ->
    d3.select(@el)
      .selectAll('rect')
      .data([{}])
      .enter()
      .append('svg:rect')
        .attr('class', 'element_bounds')
        .attr('fill', 'transparent')
        .attr('stroke', 'transparent')
        .attr('x', (d)-> -50)
        .attr('y', (d)-> -50)
        .attr('width', '100px')
        .attr('height', '100px')
        .style("stroke-dasharray", "4,4")
    
    d3.select(@el)
      .selectAll('path')
      .data(@paths)
      .enter()
      .append('svg:path')
        .attr('d', (d)-> d.get('path'))
        .attr('cx', (d)-> d.get('x'))
        .attr('cy', (d)-> d.get('y'))
        .attr('fill', (d)-> d.get('fill'))
        .attr('stroke', (d)-> d.get('stroke'))
        .attr('stroke-width', (d)-> d.get('stroke_width'))
    
    d3.select(@el)
      .selectAll('text')
      .data(@texts)
      .enter()
      .append('svg:text')
      .text((d)-> d.get('text'))