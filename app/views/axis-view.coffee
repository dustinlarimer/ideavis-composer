mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class AxisView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super
    @view      = d3.select(@el)
    #@baseline  = @view.selectAll('path.baseline')
    #@tickline  = @view.selectAll('path.tickline')
    @label     = @view.selectAll('text')
    @textline = mediator.defs
      .append('svg:path')
        .attr('id', 'axis_' + @model.id + '_path')
        .attr('class', 'textline')
    
    @subscribeEvent 'clear_active', @clear
    
    @listenTo @model, 'change', @reset

  render: ->
    super
    @build()
    console.log '[AxisView Rendered]'

  activate: ->
    @view.classed 'active', true
    console.log 'active!'
    @build_points()

  deactivate: ->
    @view.selectAll('circle.center').remove()
    @view.selectAll('circle.endpoint').remove()
    @render()

  reset: =>
    @render()
    @build_points()

  clear: ->
    @view.classed 'active', false
    @deactivate()


  build: =>
    @view.selectAll('path.baseline').remove()
    baseline = @view.selectAll('path.baseline').data([@model])
    baseline
      .enter()
      .append('svg:path')
      .attr('class', 'baseline')
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

    baseline
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
    baseline
      .exit()
      .remove()

    @view.selectAll('path.tickline').remove()
    tickline = @view.selectAll('path.tickline').data([@model])
    tickline
      .enter()
      .insert('path', 'path.baseline')
      .attr('class', 'tickline')
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

    tickline
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
    tickline
      .exit()
      .remove()

    @textline
      .attr('d', =>
        return '' +
          'M ' + @model.get('endpoints')[0][0] + ', ' + @model.get('endpoints')[0][1] +
          'L ' + @model.get('endpoints')[1][0] + ', ' + @model.get('endpoints')[1][1]
      )

    @label = @label.data([@model])
    @label
      .enter()
      .append('svg:text')
      .attr('font-family', 'Helvetica, sans-serif')
      .attr('fill', (d)-> d.get('label_fill'))
      .attr('fill-opacity', (d)-> d.get('label_fill_opacity')/100)
      .attr('font-size', (d)-> d.get('label_font_size'))
      .attr('font-style', (d)-> if d.get('label_italic') then return 'italic' else return 'normal')
      .attr('font-weight', (d)-> if d.get('label_bold') then return 'bold' else return 'normal')
      .append('svg:textPath')
        .attr('class', 'textpath')
        .attr('xlink:href', (d)-> '#axis_' + d.id + '_path')
        .attr('letter-spacing', (d)-> d.get('label_spacing'))
        .attr('startOffset', (d)->
          _align = d.get('label_align')
          _offset = d.get('label_offset_x')
          if _align is 'start' then return _offset + '%' else if _align is 'end' then return (100 - _offset) + '%' else return '50%'
        )
        .attr('text-anchor', (d)-> d.get('label_align'))
        .append('svg:tspan')
          .attr('class', 'tspan')
          .attr('dy', (d)-> -1 * d.get('label_offset_y'))
          .text((d)-> d.get('label_text'))

    @label
      .attr('fill', (d)-> d.get('label_fill'))
      .attr('fill-opacity', (d)-> d.get('label_fill_opacity')/100)
      .attr('font-size', (d)-> d.get('label_font_size'))
      .attr('font-style', (d)-> if d.get('label_italic') then return 'italic' else return 'normal')
      .attr('font-weight', (d)-> if d.get('label_bold') then return 'bold' else return 'normal')
      .transition()
        .ease('linear')
        .selectAll('.textpath')
          .attr('letter-spacing', (d)-> d.get('label_spacing'))
          .attr('startOffset', (d)->
            _align = d.get('label_align')
            _offset = d.get('label_offset_x')
            if _align is 'start' then return _offset + '%' else if _align is 'end' then return (100 - _offset) + '%' else return '50%'
          )
          .attr('text-anchor', (d)-> d.get('label_align'))
          .selectAll('.tspan')
            .attr('dy', (d)-> -1 * d.get('label_offset_y'))
            .text((d)-> d.get('label_text'))

    @label
      .exit()
      .remove()
      

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
    d3.event.sourceEvent.stopPropagation()

  drag_endpoint_move: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    d.x = d3.event.x
    d.y = d.y
    d3.select(@view.selectAll('circle.endpoint')[0][i])
      .attr('cx', (d)-> return d.x)
      .attr('cy', (d)-> return d.y)

  drag_endpoint_end: (d,i) =>
    if i is 0
      @model.save endpoints: [ [d.x, d.y], @model.get('endpoints')[1] ]
    else
      @model.save endpoints: [ @model.get('endpoints')[0], [d.x, d.y] ]
    mediator.publish 'refresh_canvas'
    @build()


