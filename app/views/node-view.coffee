mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class NodeView extends View
  autoRender: true
  
  initialize: (data={}) ->
    @paths = @model.paths.models
    @texts = @model.texts.models
    @subscribeEvent 'deactivate_detail', @deactivate

  render: ->
    # ----------------------------------
    # Bounding Box (Group)
    # ----------------------------------
    d3.select(@el)
      .selectAll('rect')
      .data([{}])
      .enter()
      .append('svg:rect')
        .attr('class', 'bounds')
        .attr('fill', 'transparent')
        .attr('opacity', 0)
        .attr('x', (d)-> -50.5)
        .attr('y', (d)-> -50.5)
        .attr('width', '101')
        .attr('height', '101')
        .style('stroke-dasharray', '4,4')


    # ----------------------------------
    # @Paths
    # ----------------------------------
    d3.select(@el)
      .selectAll('g.nodePath')
      .data(@paths)
      .enter()
      .append('svg:g')
        .attr('class', 'nodePath')
        #.attr('transform', (d)-> 'translate('+ d.get('x') + ',' + d.get('y') + ')' )
        .append('svg:path')
          .attr('class', 'artifact')
          .attr('d', (d)-> d.get('path'))
          .attr('cx', (d)-> d.get('x'))
          .attr('cy', (d)-> d.get('y'))
          .attr('fill', (d)-> d.get('fill'))
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-width', (d)-> d.get('stroke_width'))


    # ----------------------------------
    # @Texts
    # ----------------------------------
    d3.select(@el)
      .selectAll('g.nodeText')
      .data(@texts)
      .enter()
      .append('svg:g')
        .attr('class', 'nodeText')
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ')' )
        .append('svg:text')
          .attr('class', 'artifact')
          .attr('dx', 0)
          .attr('dy', 0)
          .attr('text-anchor', 'middle')
          .text((d)-> d.get('text'))


  activate: ->
    # ----------------------------------
    # Bounding Boxes (Texts)
    # ----------------------------------
    d3.select(@el)
      .selectAll('g.nodeText')
      .call(d3.behavior.drag()
        .on('dragstart', @drag_text_start)
        .on('drag', @drag_text_move)
        .on('dragend', @drag_text_end))
      .insert('rect', 'text.artifact')
        .attr('class', 'bounds')
        .attr('fill', 'transparent')
        .style('stroke-dasharray', '4,4')
        .each((d,i)->
          this.ref = $(this).next('text')[0].getBoundingClientRect()
          console.log this.ref
          d.height = this.ref.height + 10
          d.width = this.ref.width + 30
          d.x = -1 * this.ref.width/2 - 15
          d.y = -1 * this.ref.height/2 - 10
        )
        .attr('height', (d)-> return d.height)
        .attr('width', (d)-> return d.width)
        .attr('x', (d)-> return d.x)
        .attr('y', (d)-> return d.y)


    # ----------------------------------
    # Bounds Center Origin
    # ----------------------------------
    d3.select(@el)
      .selectAll('path.origin')
      .data([{}])
      .enter()
      .append('svg:path')
        .attr('class', 'origin')
        .attr('d', 'M 0,-12 L 0,12 M -12,0 L 12,0')
        .attr('fill', 'transparent')
        .attr('stroke', '#000000')
        .attr('stroke-width', 1)
        .attr('opacity', 0)
        .style('stroke-dasharray', '4,1')
    

  deactivate: ->
    d3.select(@el).selectAll('path.origin').remove()
    d3.select(@el).selectAll('g.nodeText rect.bounds').remove()
    d3.select(@el).selectAll('g.nodeText')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))


  drag_text_start: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    console.log @model.texts

  drag_text_move: (d,i) ->
    d3.event.sourceEvent.stopPropagation()
    d.x = d3.event.x
    d.y = d3.event.y
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ')')

  drag_text_end: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    d.set x: d.x, y: d.y


