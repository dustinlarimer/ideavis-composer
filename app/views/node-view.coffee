mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class NodeView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super
    
    @subscribeEvent 'clear_active', @clear
    
    @listenTo @model, 'change', @render
    #@listenTo @model.paths, 'change', @build_paths
    #@listenTo @model.texts, 'change', @build_texts
    #@listenTo @model.paths, 'change', @build_bounding_boxes
    #@listenTo @model.texts, 'change', @build_bounding_boxes

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
      #.selectAll('g.nodeText')
      #.attr('cursor', 'move')
      #.call(d3.behavior.drag()
      #  .on('dragstart', @drag_text_start)
      #  .on('drag', @drag_text_move)
      #  .on('dragend', @drag_text_end))
    @build_origin()

  #deactivate: ->
  #  d3.select(@el).select('path.origin').remove()
  #  d3.select(@el).selectAll('g.nodePath').remove()
  #  d3.select(@el).selectAll('g.nodeText').remove()
  #  @clear()
  #  @render()

  clear: ->
    d3.select(@el).classed 'active', false


  # ----------------------------------
  # BUILD @Paths
  # ----------------------------------
  build_paths: =>
    d3.select(@el).selectAll('g.nodePath').remove()
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
          .attr('shape-rendering', 'geometricPrecision')
          #.attr('d', (d)-> d.path)
          .attr('fill', (d)-> d.get('fill'))
          .attr('fill-opacity', (d)-> d.get('fill_opacity')/100)
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-width', (d)-> d.get('stroke_width'))
          .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
          .attr('stroke-linecap', (d)-> d.get('stroke_linecap'))
          .attr('stroke-linejoin', (d)-> 
            _linecap = d.get('stroke_linecap')
            if _linecap is 'square' then return 'miter' else if _linecap is 'butt' then return 'bevel' else return _linecap
          )
          .attr('stroke-dasharray', (d)-> d.get('stroke_dasharray').join())
    
    path
      .transition()
        .ease('linear')
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') scale(' + d.get('scale') + ') rotate(' + d.get('rotate') + ')' )
        .selectAll('path.artifact')
          #.attr('d', (d)-> d.path)
          .attr('fill', (d)-> d.get('fill'))
          .attr('fill-opacity', (d)-> d.get('fill_opacity')/100)
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-width', (d)-> d.get('stroke_width'))
          .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
          .attr('stroke-linecap', (d)-> d.get('stroke_linecap'))
          .attr('stroke-linejoin', (d)-> 
            _linecap = d.get('stroke_linecap')
            if _linecap is 'square' then return 'miter' else if _linecap is 'butt' then return 'bevel' else return _linecap
          )
    
    path
      .selectAll('path.artifact')
        .each((d,i)=> @generate_shape(d))
        .attr('d', (d)-> d.path)
        .attr('stroke-dasharray', (d)-> d.get('stroke_dasharray').join())
    
    path
      .exit()
      .remove()


  # ----------------------------------
  # BUILD @Texts
  # ----------------------------------
  build_texts: ->
    d3.select(@el).selectAll('g.nodeText').remove()
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
          .attr('dx', 0)
          .attr('dy', (d)-> d.get('font_size')/3)
          .attr('fill', (d)-> d.get('fill'))
          .attr('fill-opacity', (d)-> d.get('fill_opacity')/100)
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
          .attr('text-anchor', 'middle')
          .attr('text-rendering', 'optimizeLegibility')
          .attr('font-family', 'Helvetica, sans-serif')
          #.attr('font-family', (d)-> d.get('font_family'))
          .attr('font-size', (d)-> d.get('font_size'))
          .attr('font-style', (d)-> if d.get('italic') then return 'italic' else return 'normal')
          .attr('font-weight', (d)-> if d.get('bold') then return 'bold' else return 'normal')
          .attr('text-decoration', (d)->
            _deco = []
            if d.get('underline') then _deco.push('underline')
            if d.get('overline') then _deco.push('overline')
            return _deco.join(' ')
          )
          .attr('letter-spacing', (d)-> d.get('spacing'))
          .attr('stroke-width', (d)-> d.get('stroke_width'))
          .text((d)-> d.get('text'))

    
    text
      .transition()
        .ease('linear')
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')' )
        .selectAll('text.artifact')
          .text((d)-> d.get('text'))
          .attr('dy', (d)-> d.get('font_size')/3)
          .attr('font-size', (d)-> d.get('font_size'))
          .attr('fill', (d)-> d.get('fill'))
          .attr('fill-opacity', (d)-> d.get('fill_opacity')/100)
          .attr('stroke-width', (d)-> d.get('stroke_width'))
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
          .attr('font-weight', (d)-> if d.get('bold') then return 'bold' else return 'normal')
          .attr('font-style', (d)-> if d.get('italic') then return 'italic' else return 'normal')
          .attr('text-decoration', (d)->
            _deco = []
            if d.get('underline') then _deco.push('underline')
            if d.get('overline') then _deco.push('overline')
            return _deco.join(' ')
          )
          .attr('letter-spacing', (d)-> d.get('spacing'))
   
    text
      .exit()
      .remove()

  # ----------------------------------
  # BUILD Bounding Boxes
  # ----------------------------------
  build_bounding_boxes: ->
    # Remove all existing bounding boxes
    d3.select(@el).select('rect.parent_bounds').remove()
    
    setTimeout =>
      @build_artifact_bounding_boxes()
      _parent = d3.select(@el)[0][0].getBBox()
      
      d3.select(@el)
        .selectAll('rect.parent_bounds')
        .data([{}])
        .enter()
        .insert('rect', 'g.nodePath')
          .attr('class', 'bounds parent_bounds')
          .attr('shape-rendering', 'crispEdges')
          .attr('opacity', 0)
          .attr('fill', 'none')
          .attr('height', (d)-> return _parent.height + 20.5)
          .attr('width', (d)-> return _parent.width + 20.5)
          .attr('x', (d)-> return _parent.x - 10.25)
          .attr('y', (d)-> return _parent.y - 10.25)
          .style('stroke-dasharray', '4,4')
          .transition()
            .ease Math.sqrt
    , 250


  # ----------------------------------
  # BUILD Artifact Bounding Boxes
  # ----------------------------------

  build_artifact_bounding_boxes: ->
    # TEXT
    d3.select(@el).selectAll('g.nodeText rect.bounds').remove()
    d3.select(@el)
      .selectAll('g.nodeText')
      #.selectAll('rect.text_bounds')
      #.data([{}])
      #.enter()
      .insert('rect', 'text.artifact')
        .attr('class', 'bounds')
        .attr('shape-rendering', 'crispEdges')
        .attr('fill', 'none')
        .each((d,i)->
          this.ref = $(this).next('text')[0].getBoundingClientRect()
          d.width = this.ref.width
        )
        .attr('height', (d)=> return d.get('font_size') - d.get('font_size')/4 + 10.5)
        .attr('width', (d)-> return d.width + 10)
        .attr('x', (d)-> return -1 * (d.width/2) - 5.25)
        .attr('y', (d)-> return -1 * d.get('font_size')/2 - d.get('font_size')/4 - 5 + d.get('font_size')/3)
        .style('stroke-dasharray', '4,4')


  # ----------------------------------
  # BUILD Center Origin
  # ----------------------------------

  build_origin: ->
    d3.select(@el).select('path.origin').remove()
    d3.select(@el)
      .selectAll('path.origin')
      .data([{}])
      .enter()
      .insert('path', 'g.nodeText')
        .attr('class', 'origin')
        .attr('shape-rendering', 'crispEdges')
        .attr('fill', 'none')
        .attr('d', 'M 0,-12 L 0,12 M -12,0 L 12,0')
        .style('stroke-dasharray', '4,1')


  # ----------------------------------
  # DRAG Methods
  # ----------------------------------

  drag_text_start: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    console.log 'drag_text_start'
    d.px = d.get('x')
    d.py = d.get('y')

  drag_text_move: (d,i) ->
    d3.event.sourceEvent.stopPropagation()
    console.log 'drag_text_move'
    d.px = Math.round(d3.event.x)
    d.py = Math.round(d3.event.y)
    d3.select(@).attr('transform', 'translate('+ d.px + ',' + d.py + ') rotate(' + d.get('rotate') + ')' )

  drag_text_end: (d,i) =>
    console.log 'drag_text_end'
    unless d.px is d.get("x")
      d.set x: d.px, y: d.py
      @build_bounding_boxes()








  # ----------------------------------
  # GENERATE Shapes
  # ----------------------------------
  generate_shape: (d) =>
    shape  = d.get('shape')
    height = d.get('height')
    width  = d.get('width')
    
    switch shape
      when 'none'
        d.path = 'M 0,0 L 0,0 Z'
        break
      when 'circle'
        d.path = '' + 
          'M 0,0 ' + 
          'm ' + (-width/2) + ', 0 ' + 
          'a ' + (width/2) + ',' + (height/2) + ' 0 1,0 ' + (width) + ',0 ' + 
          'a ' + (width/2) + ',' + (height/2) + ' 0 1,0 ' + (-width) + ',0'
        break
      when 'square'
        d.path = '' + 
          'M ' + (-width/2) + ',' + (-height/2) + ' ' + 
          'L ' + (width/2) + ',' + (-height/2) + ' ' + 
          'L ' + (width/2) + ',' + (height/2) + ' ' + 
          'L ' + (-width/2) + ',' + (height/2) + ' Z'
        break
      when 'hexagon'
        d.path = '' + 
          'M 0,' + (-height/2) + ' ' + 
          'L ' + (width/2) + ',' + (-height/4) + ' ' + 
          'L ' + (width/2) + ',' + (height/4) + ' ' + 
          'L 0,' + (height/2) + ' ' + 
          'L ' + (-width/2) + ',' + (height/4) + ' ' + 
          'L ' + (-width/2) + ',' + (-height/4) + ' Z'
        break
      when 'triangle'
        d.path = '' + 
          'M 0,' + (-height/2) + ' ' + 
          'L ' + (width/2) + ',' + (height/2) + ' ' + 
          'L ' + (-width/2) + ',' + (height/2) + ' Z'
        break
      when 'plus'
        d.path = '' + 
          'M ' + (-width*.5) + ',' + (-height*.2) + ' ' + 
          'L ' + (-width*.2) + ',' + (-height*.2) + ' ' +
          'L ' + (-width*.2) + ',' + (-height*.5) + ' ' + 
          'L ' + (width*.2)  + ',' + (-height*.5) + ' ' + 
          'L ' + (width*.2)  + ',' + (-height*.2) + ' ' + 
          'L ' + (width*.5)  + ',' + (-height*.2) + ' ' + 
          'L ' + (width*.5)  + ',' + (height*.2)  + ' ' + 
          'L ' + (width*.2)  + ',' + (height*.2)  + ' ' + 
          'L ' + (width*.2)  + ',' + (height*.5)  + ' ' + 
          'L ' + (-width*.2) + ',' + (height*.5)  + ' ' +
          'L ' + (-width*.2) + ',' + (height*.2)  + ' ' +
          'L ' + (-width*.5) + ',' + (height*.2)  + ' Z'
        break


