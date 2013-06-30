mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class NodeView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super
    #@paths = @model.paths.models
    @texts = @model.texts.models
    @subscribeEvent 'deactivate_detail', @deactivate
    @subscribeEvent 'clear_active', @clear
    
    @listenTo @model.paths, 'change', @build_paths
    @listenTo @model.texts, 'change', @build_texts

  render: ->
    super
    @build_paths()
    @build_texts()
    @build_bounding_boxes()
    console.log '[NodeView Rendered]'

  remove: ->
    console.log '[NodeView Removed]'
    super

  activate: ->
    d3.select(@el)
      .classed('active', true)
      .selectAll('g.nodeText')
      .attr('cursor', 'move')
      .call(d3.behavior.drag()
        .on('dragstart', @drag_text_start)
        .on('drag', @drag_text_move)
        .on('dragend', @drag_text_end))
    @build_origin()

  deactivate: ->
    d3.select(@el).select('path.origin').remove()
    d3.select(@el).selectAll('g.nodePath').remove()
    d3.select(@el).selectAll('g.nodeText').remove()
    @clear()
    @render()

  clear: ->
    d3.select(@el).classed 'active', false

  # ----------------------------------
  # BUILD @Paths
  # ----------------------------------
  build_paths: =>
    path = d3.select(@el)
      .selectAll('g.nodePath')
      .data(@model.paths.models)
    
    path
      .enter()
      .append('svg:g')
        .attr('class', 'nodePath')
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') scale(' + d.get('scale') + ') rotate(' + d.get('rotate') + ')' )
        .append('svg:path')
          .attr('class', 'artifact')
          .attr('d', (d)-> d.get('path'))
          .attr('fill', (d)-> d.get('fill'))
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-width', (d)-> d.get('stroke_width'))
    
    path
      .transition()
        .ease(Math.sqrt)
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') scale(' + d.get('scale') + ') rotate(' + d.get('rotate') + ')' )
        .selectAll('path.artifact')
          .attr('fill', (d)-> d.get('fill'))
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-width', (d)-> d.get('stroke_width'))
    
    path
      .selectAll('path.artifact')
        .attr('d', (d)-> d.get('path'))
          
    
    path
      .exit()
      .remove()


  # ----------------------------------
  # BUILD @Texts
  # ----------------------------------
  build_texts: ->    
    text = d3.select(@el)
      .selectAll('g.nodeText')
      .data(@model.texts.models)

    text
      .enter()
      .append('svg:g')
        .attr('class', 'nodeText')
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')' )
        .append('svg:text')
          .attr('class', 'artifact')
          .text((d)-> d.get('text'))
          .attr('dx', 0)
          .attr('dy', 0)
          .attr('letter-spacing', '0px')
          #.attr('text-decoration', 'underline overline')
          .attr('font-family', (d)-> d.get('font_family'))
          .attr('font-size', (d)-> d.get('font_size'))
          .attr('font-weight', (d)-> d.get('font_weight'))
          .attr('fill', (d)-> d.get('fill'))
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-width', (d)-> d.get('stroke_width'))
          .attr('text-anchor', 'middle')
    
    text
      .transition()
        .ease(Math.sqrt)
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')' )
        .selectAll('text.artifact')
          .attr('fill', (d)-> d.get('fill'))
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-width', (d)-> d.get('stroke_width'))

    text
      .selectAll('text.artifact')
        .text((d)-> d.get('text'))
        .attr('font-family', (d)-> d.get('font_family'))
        .attr('font-size', (d)-> d.get('font_size'))
        .attr('font-weight', (d)-> d.get('font_weight'))
    
    text
      .exit()
      .remove()

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
          d.width = this.ref.width
        )
        .attr('height', (d)-> return d.get('font_size') - d.get('font_size')/4 + 10)
        .attr('width', (d)-> return d.width + 10)
        .attr('x', (d)-> return -1 * (d.width/2) - 5)
        .attr('y', (d)-> return -1 * d.get('font_size')/2 - d.get('font_size')/4 - 5)


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

