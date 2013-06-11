View = require 'views/base/view'

module.exports = class NodeView extends View
  autoRender: true
  className: 'nodeGroup'
  tagName: 'g'
  
  initialize: (data={}) ->
    @paths = _.where(@model.get('nested'), {type: 'path'})
    @texts = _.where(@model.get('nested'), {type: 'text'})
    #@delegate 'click', 'path', @nodePathSelected

  #listen:
  #  'change model': -> console.log @model

  nodePathSelected: (e) ->
    e.preventDefault()
    console.log this

  select: ->
    d3.select(@el).attr('class', 'selected')

  render: ->
    #console.log d3.select(@el).data(@paths)
    d3.select(@el).data(@paths)
      .append('svg:path')
      .attr('d', (d) -> d.path)
      .attr('cx', (d) -> d.x)
      .attr('cy', (d) -> d.y)
      .attr('fill', (d) -> d.fill)
      .attr('stroke', (d) -> d.stroke)
      .attr('stroke-width', (d) -> d.stroke_width)
    d3.select(@el).data(@texts)
      .append('svg:text')
      .text((d) -> d.text)
      .attr('contenteditable', true)
    #d3.select(@el).attr('transform', 'translate('+@model.get('x')+','+@model.get('y')+')')