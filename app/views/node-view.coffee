mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class NodeView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super
    @paths = @model.paths.models
    @texts = @model.texts.models
    @subscribeEvent 'deactivate_detail', @deactivate
    @subscribeEvent 'clear_active_nodes', @deactivate

  render: ->
    super
    @build_paths()
    @build_texts()
    @build_parent_bounding_box()

  remove: ->
    console.log '[NodeView Removed]'
    super

  activate: ->
    @deactivate()
    d3.select(@el).classed 'active', true
    @build_artifact_bounding_boxes()
    @build_origin()

  deactivate: ->
    d3.select(@el).classed 'active', false
    d3.select(@el).select('path.origin').remove()
    d3.select(@el).selectAll('g.nodePath').remove()
    d3.select(@el).selectAll('g.nodeText').remove()
    @build_paths()
    @build_texts()


  # ----------------------------------
  # BUILD Parent Bounding Box
  # ----------------------------------
  build_parent_bounding_box: =>
    _parent = d3.select(@el)[0][0].getBBox()
    d3.select(@el)
      .selectAll('rect.parent_bounds')
      .data([{}])
      .enter()
      .insert('rect', 'g.nodePath')
        .attr('class', 'bounds parent_bounds')
        .attr('fill', 'transparent')
        .attr('opacity', 0)
        .attr('height', (d)-> return _parent.height + 30)
        .attr('width', (d)-> return _parent.width + 30)
        .attr('x', (d)-> return _parent.x - 15)
        .attr('y', (d)-> return _parent.y - 15)
        .style('stroke-dasharray', '4,4')
        .transition()
          .ease Math.sqrt


  # ----------------------------------
  # BUILD @Paths
  # ----------------------------------
  build_paths: ->
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
  # BUILD @Texts
  # ----------------------------------
  build_texts: ->
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


  # ----------------------------------
  # BUILD Artifact Bounding Boxes
  # ----------------------------------
  build_artifact_bounding_boxes: ->
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
          d.height = this.ref.height + 10
          d.width = this.ref.width + 20
          d.x = -1 * this.ref.width/2 - 10
          d.y = -1 * this.ref.height/2 - 10
        )
        .attr('height', (d)-> return d.height)
        .attr('width', (d)-> return d.width)
        .attr('x', (d)-> return d.x)
        .attr('y', (d)-> return d.y)


  # ----------------------------------
  # BUILD Center Origin
  # ----------------------------------
  build_origin: ->
    d3.select(@el)
      .selectAll('path.origin')
      .data([{}])
      .enter()
      .insert('path', 'g.nodeText')
        .attr('class', 'origin')
        .attr('d', 'M 0,-12 L 0,12 M -12,0 L 12,0')
        .attr('fill', 'transparent')
        .attr('stroke', '#000000')
        .attr('stroke-width', 1)
        .attr('opacity', 0)
        .style('stroke-dasharray', '4,1')


  # ----------------------------------
  # DRAG Methods
  # ----------------------------------

  drag_text_start: (d,i) =>
    console.log 'node:drag_text_start'

  drag_text_move: (d,i) ->
    d.x = d3.event.x
    d.y = d3.event.y
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ')')

  drag_text_end: (d,i) =>
    console.log 'node:drag_text_end'
    d.set x: d.x, y: d.y
    
    d3.select(@el).select('rect.parent_bounds').remove()
    @build_parent_bounding_box()

