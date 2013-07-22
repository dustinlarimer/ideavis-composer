mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class AxisView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super

    @view      = d3.select(@el)
    @baseline  = @view.selectAll('path.baseline')
    @label     = @view.selectAll('text.label')
    @center    = @view.selectAll('circle.center')
    @endpoints = @view.selectAll('circle.endpoint')

    @subscribeEvent 'deactivate_detail', @deactivate
    @subscribeEvent 'clear_active', @clear

  render: ->
    super
    console.log '[AxisView Rendered]'
    @build()

  activate: ->
    console.log 'Axis activated!'
    d3.select(@el).classed 'active', true

  deactivate: ->
    @clear()
    @render()

  clear: ->
    @view.classed 'active', false

  build: =>
    @baseline = @baseline.data([@model])
    @baseline
      .enter()
      .append('svg:path')
      .attr('class', 'baseline')
      .attr('shape-rendering', 'crispEdges')
      .attr('stroke', (d)-> d.get('stroke'))
      .attr('stroke-dasharray', (d)-> d.get('stroke_dasharray'))
      .attr('stroke-linecap', (d)-> d.get('stroke_linecap'))
      .attr('stroke-linejoin', (d)-> d.get('stroke_linecap'))
      .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
      .attr('stroke-width', (d)-> d.get('stroke_width'))
      .attr('d', (d)->
        return '' +
          'M ' + d.get('endpoints')[0][0] + ', ' + d.get('endpoints')[0][1] +
          'L ' + d.get('endpoints')[1][0] + ', ' + d.get('endpoints')[1][1]
      )

    @center = @center.data([@model])
    @center
      .enter()
      .append('svg:circle')
      .attr('class', 'center')
      .attr('cx', (d)-> return d.x)
      .attr('cy', (d)-> return d.y)
      .attr('r', 5)
      .attr('fill', (d)=> @model.get('stroke'))
      .attr('stroke', '#fff')
      .attr('stroke-width', 2)
      .attr('cursor', 'move')
      #.call(d3.behavior.drag()
      #  .on('dragstart', @drag_center_start)
      #  .on('drag', @drag_center_move)
      #  .on('dragend', @drag_center_end))

    endpoint_data = [
      { x: @model.get('endpoints')[0][0], y: @model.get('endpoints')[0][1] },
      { x: @model.get('endpoints')[1][0], y: @model.get('endpoints')[1][1] }
    ]
    @endpoints = @endpoints.data(endpoint_data)
    @endpoints
      .enter()
      .append('svg:circle')
      .attr('class', 'endpoint')
      .attr('cx', (d,i)-> return d.x)
      .attr('cy', (d,i)-> return d.y)
      .attr('r', 5)
      .attr('fill', (d)=> @model.get('stroke'))
      .attr('stroke', '#fff')
      .attr('stroke-width', 2)
      .attr('cursor', 'move')

  drag_center_start: (d,i) =>
    mediator.zoom = false
    #console.log 'starting'

  drag_center_move: (d,i) =>
    mediator.zoom = false
    d.x = d3.event.x
    d.y = d3.event.y
    @center
      .attr('cx', (d)-> return d.x)
      .attr('cy', (d)-> return d.y)

  drag_center_end: (d,i) =>
    mediator.zoom = true
    @model.save x: d.x, y: d.y
    mediator.publish 'refresh_canvas'





