mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class AxisView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super

    @view      = d3.select(@el)
    @baseline  = @view.selectAll('path.baseline')
    @tickline  = @view.selectAll('path.tickline')
    @label     = @view.selectAll('text.label')
    #@center    = @view.selectAll('circle.center')
    #@endpoints = @view.selectAll('circle.endpoint')

    @selected_endpoint = null

    #@subscribeEvent 'deactivate_detail', @deactivate
    @subscribeEvent 'clear_active', @clear

    #@listenTo @model, 'change', @render

  render: ->
    super
    console.log '[AxisView Rendered]'
    @build()

  activate: ->
    console.log 'Axis activated!'
    @view.classed 'active', true
    @build_points()

  deactivate: ->
    @view.selectAll('circle.center').remove()
    @view.selectAll('circle.endpoint').remove()
    @render()

  clear: ->
    @view.classed 'active', false
    @deactivate()

  build: =>
    @baseline = @baseline.data([@model])
    @baseline
      .enter()
      .append('svg:path')
      .attr('class', 'baseline')
      #.attr('shape-rendering', 'crispEdges')
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

    @baseline
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

    @tickline = @tickline.data([@model])
    @tickline
      .enter()
      .insert('path', 'path.baseline')
      .attr('class', 'tickline')
      #.attr('shape-rendering', 'crispEdges')
      .attr('stroke', (d)-> d.get('stroke'))
      .attr('stroke-dasharray', (d)-> d.get('stroke_dasharray'))
      .attr('stroke-linecap', (d)-> d.get('stroke_linecap'))
      .attr('stroke-linejoin', (d)-> d.get('stroke_linecap'))
      .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
      .attr('stroke-width', (d)-> 
        _sw = d.get('stroke_width')
        if _sw < 8 then return 8 else return _sw
      )
      .attr('d', (d)->
        return '' +
          'M ' + d.get('endpoints')[0][0] + ', ' + d.get('endpoints')[0][1] +
          'L ' + d.get('endpoints')[1][0] + ', ' + d.get('endpoints')[1][1]
      )
      .attr('visibility', 'hidden')

    @tickline
      .attr('stroke', (d)-> d.get('stroke'))
      .attr('stroke-dasharray', (d)-> d.get('stroke_dasharray'))
      .attr('stroke-linecap', (d)-> d.get('stroke_linecap'))
      .attr('stroke-linejoin', (d)-> d.get('stroke_linecap'))
      .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
      .attr('stroke-width', (d)-> 
        _sw = d.get('stroke_width')
        if _sw < 8 then return 8 else return _sw
      )
      .attr('d', (d)->
        return '' +
          'M ' + d.get('endpoints')[0][0] + ', ' + d.get('endpoints')[0][1] +
          'L ' + d.get('endpoints')[1][0] + ', ' + d.get('endpoints')[1][1]
      )

  build_points: =>
    
    @view.selectAll('circle.center').remove()

    center = @view.selectAll('circle.center').data([@model])

    center
      .enter()
      .append('svg:circle')
      .attr('class', 'center')
      .attr('cx', 0)
      .attr('cy', 0)
      .attr('r', 5)
      .attr('fill', (d)=> @model.get('stroke'))
      .attr('stroke', '#fff')
      .attr('stroke-width', 2)
      .attr('cursor', 'move')

    center
      .exit()
      .remove()

    @view.selectAll('circle.endpoint').remove()
    endpoint_data = [
      { x: @model.get('endpoints')[0][0], y: @model.get('endpoints')[0][1] },
      { x: @model.get('endpoints')[1][0], y: @model.get('endpoints')[1][1] }
    ]
    endpoints = @view.selectAll('circle.endpoint').data(endpoint_data)
    endpoints
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
      .call(d3.behavior.drag()
        .on('dragstart', @drag_endpoint_start)
        .on('drag', @drag_endpoint_move)
        .on('dragend', @drag_endpoint_end))

    endpoints
      .exit()
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
      .remove()


  drag_endpoint_start: (d,i) =>
    mediator.zoom = false
    d3.event.sourceEvent.stopPropagation()

  drag_endpoint_move: (d,i) =>
    mediator.zoom = false
    d.x = d3.event.x
    d.y = d.y
    d3.select(@view.selectAll('circle.endpoint')[0][i])
      .attr('cx', (d)-> return d.x)
      .attr('cy', (d)-> return d.y)

  drag_endpoint_end: (d,i) =>
    mediator.zoom = true
    if i is 0
      @model.save endpoints: [ [d.x, d.y], @model.get('endpoints')[1] ]
    else
      @model.save endpoints: [ @model.get('endpoints')[0], [d.x, d.y] ]
    mediator.publish 'refresh_canvas'
    @build()


