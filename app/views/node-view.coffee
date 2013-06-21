mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class NodeView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super
    @paths = @model.paths.models
    @texts = @model.texts.models
    #@deactivate()
    
    @subscribeEvent 'deactivate_detail', @deactivate
    @subscribeEvent 'clear_active_nodes', @deactivate

  render: ->
    super
    @build_paths()
    @build_texts()
    @build_bounding_boxes()

  remove: ->
    console.log '[NodeView Removed]'
    super

  activate: ->
    d3.select(@el)
      .classed('active', true)
      .selectAll('g.nodeText')
      .call(d3.behavior.drag()
        .on('dragstart', @drag_text_start)
        .on('drag', @drag_text_move)
        .on('dragend', @drag_text_end))
    @build_origin()

  deactivate: ->
    d3.select(@el).classed 'active', false
    d3.select(@el).select('path.origin').remove()
    d3.select(@el).selectAll('g.nodePath').remove()
    d3.select(@el).selectAll('g.nodeText').remove()
    @render()


  # ----------------------------------
  # BUILD @Paths
  # ----------------------------------
  build_paths: =>
    path = d3.select(@el).selectAll('g.nodePath')
    path
      .data(@paths)
      .enter()
      .append('svg:g')
        .attr('class', 'nodePath')
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') scale(' + d.get('scale') + ') rotate(' + d.get('rotate') + ')' )
        .append('svg:path')
          .attr('class', 'artifact')
          .attr('fill', (d)-> d.get('fill'))
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-width', (d)-> d.get('stroke_width'))
          .attr('d', (d)-> d.get('path'))
    path
      .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') scale(' + d.get('scale') + ') rotate(' + d.get('rotate') + ')' )


  # ----------------------------------
  # BUILD @Texts
  # ----------------------------------
  build_texts: ->
    text = d3.select(@el).selectAll('g.nodeText')
    text
      .data(@texts)
      .enter()
      .append('svg:g')
        .attr('class', 'nodeText')
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')' )
        .append('svg:text')
          .attr('class', 'artifact')
          .attr('font-family', (d)-> d.get('font_family'))
          .attr('font-size', (d)-> d.get('font_size'))
          .attr('font-weight', (d)-> d.get('font_weight'))
          .attr('dx', 0)
          .attr('dy', 0)
          .attr('text-anchor', 'middle')
          .text((d)-> d.get('text'))
    text
      .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')' )
      .selectAll('text.artifact')
      .attr('font-family', (d)-> d.get('font_family'))
      .attr('font-size', (d)-> d.get('font_size'))
      .attr('font-weight', (d)-> d.get('font_weight'))


  # ----------------------------------
  # BUILD Bounding Boxes
  # ----------------------------------
  build_bounding_boxes: =>
    # Remove all existing bounding boxes
    d3.select(@el).selectAll('rect.bounds').remove()
    
    @build_artifact_bounding_boxes()
    _parent = d3.select(@el)[0][0].getBBox()
    
    d3.select(@el)
      .selectAll('rect.parent_bounds')
      .data([{}])
      .enter()
      .insert('rect', 'g.nodePath')
        .attr('class', 'bounds parent_bounds')
        .attr('fill', 'transparent')
        .attr('opacity', 0)
        .attr('height', (d)-> return _parent.height + 20)
        .attr('width', (d)-> return _parent.width + 20)
        .attr('x', (d)-> return _parent.x - 10)
        .attr('y', (d)-> return _parent.y - 10)
        .style('stroke-dasharray', '4,4')
        .transition()
          .ease Math.sqrt


  # ----------------------------------
  # BUILD Artifact Bounding Boxes
  # ----------------------------------

  build_artifact_bounding_boxes: ->
    # TEXT
    d3.select(@el)
      .selectAll('g.nodeText')
      .insert('rect', 'text.artifact')
        .attr('class', 'bounds')
        .attr('fill', 'transparent')
        .style('stroke-dasharray', '4,4')
        .each((d,i)->
          this.ref = $(this).next('text')[0].getBoundingClientRect()
          #console.log d.get('font_size')
          console.log this.ref
          d.height = this.ref.height + d.get('font_size')/4
          d.width = this.ref.width + d.get('font_size')/2
          d.x = -1 * this.ref.width/2 - d.get('font_size')/4
          d.y = -1 * this.ref.height/2 - d.get('font_size')/2
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
    d.px = d.get('x')
    d.py = d.get('y')

  drag_text_move: (d,i) ->
    d.px = d3.event.x
    d.py = d3.event.y
    d3.select(@).attr('transform', 'translate('+ d.px + ',' + d.py + ') rotate(' + d.get('rotate') + ')' )

  drag_text_end: (d,i) =>
    unless d.px is d.get("x")
      d.set x: d.px, y: d.py
      @build_bounding_boxes()

