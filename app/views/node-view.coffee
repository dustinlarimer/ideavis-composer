mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class NodeView extends View
  autoRender: true
  
  initialize: (data={}) ->
    @paths = _.where(@model.get('nested'), {type: 'path'})
    @texts = _.where(@model.get('nested'), {type: 'text'})
    @subscribeEvent 'clear_active_nodes', @deactivate

  deactivate: ->
    d3.select(@el).attr('class', 'nodeGroup')

  render: ->
    d3.select(@el)
      .selectAll('path')
      .data(@paths)
      .enter()
      .append('svg:path')
        .attr('d', (d) -> d.path)
        .attr('cx', (d) -> d.x)
        .attr('cy', (d) -> d.y)
        .attr('fill', (d) -> d.fill)
        .attr('stroke', (d) -> d.stroke)
        .attr('stroke-width', (d) -> d.stroke_width) 
    d3.select(@el)
      .selectAll('text')
      .data(@texts)
      .enter()
      .append('svg:text')
      .text((d) -> d.text)