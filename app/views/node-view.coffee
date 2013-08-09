mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class NodeView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super

    try
      @zoom_helpers = require '/editor/lib/zoom-helpers'
      @mode = 'private'
    catch error
      @mode = 'public'

    @view = d3.select(@el)
    @resizing_text = false

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
    #@build_bounding_boxes()
    console.log '[NodeView Rendered]'
    #@publishEvent 'node_updated', @model

  remove: ->
    @deactivate()
    console.log '[NodeView Removed]'
    super

  activate: ->
    console.log 'Activating...'
    @view.classed('active', true)
      #.selectAll('g.nodeText')
      #.attr('cursor', 'move')
      #.call(d3.behavior.drag()
      #  .on('dragstart', @drag_text_start)
      #  .on('drag', @drag_text_move)
      #  .on('dragend', @drag_text_end))
    @build_controls()
    

  deactivate: =>
    console.log 'Deactivating...'
    @controls?.remove()
    @resizing_text = false
  #  d3.select(@el).select('path.origin').remove()
  #  d3.select(@el).selectAll('g.nodePath').remove()
  #  d3.select(@el).selectAll('g.nodeText').remove()
  #  @clear()
  #  @render()


  clear: ->
    @view.classed 'active', false
    @deactivate()


  build_controls: =>
    console.log 'Building node controls'
    @build_origin()
    
    mediator.controls.selectAll('g#node_controls').remove()
    @controls = mediator.controls
      .append('svg:g')
        .attr('id', 'node_controls')

    @text_controls = @controls.selectAll('g.node_text_controls').data(@model.texts.models)
    @text_controls
      .enter()
      .append('svg:g')
        .attr('class', 'node_text_controls')
        .attr('transform', (d)=> return 'translate('+ @model.get('x') + ',' + @model.get('y') + ')')
        .each((d)=> @build_handles(d))


  build_handles: (text_model) =>

    _handle = []
    _handle[0]=
      x: -(text_model.get('width')/2), y: -(text_model.get('height')/2)
    _handle[1]=
      x: text_model.get('width')/2, y: -(text_model.get('height')/2)
    _handle[2]=
      x: text_model.get('width')/2, y: text_model.get('height')/2
    _handle[3]=
      x: -(text_model.get('width')/2), y: text_model.get('height')/2

    console.log text_model
    @text_bounding_box = @text_controls.selectAll('rect.bounding_box').data([text_model])
    @text_bounding_box
      .enter()
      .append('svg:rect')
        .attr('class', 'bounding_box')
        .attr('x', (d)-> -(d.get('width')/2))
        .attr('y', (d)-> -(d.get('height')/2))
        .attr('height', (d)-> d.get('height'))
        .attr('width', (d)-> d.get('width'))
        .attr('fill', 'none')
        .attr('stroke', '#000')
        .attr('stroke-dasharray', '5,3')
        .attr('stroke-opacity', .35)

    @text_handles = @text_controls.selectAll('circle.handle').data(_handle)
    @text_handles
      .enter()
      .append('svg:circle')
        .attr('class', 'handle')
        .attr('cx', (d,i)-> d.x)
        .attr('cy', (d,i)-> d.y)
        .attr('r', 5)
        .attr('fill', '#757575')   
        .attr('cursor', 'move') 
        .call(d3.behavior.drag()
          .on('dragstart', @drag_text_handle_start)
          .on('drag', @drag_text_handle_move)
          .on('dragend', @drag_text_handle_end))


  drag_text_handle_start: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    console.log 'startz!'

  drag_text_handle_move: (d,i) =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = @zoom_helpers.get_coordinates(e)

    @resizing_text = true
    _min_height = @text_controls.data()[0].get('font_size')
    _drag_height = Math.abs(coordinates.y - @model.get('y')) * 2

    _min_width = 50
    _drag_width = Math.abs(coordinates.x - @model.get('x')) * 2


    _height = Math.max(_drag_height, _min_height)
    _width  = Math.max(_drag_width, _min_width)

    #console.log Math.round(_height) + 'px by ' + Math.round(_width) + 'px'

    @text_bounding_box
      .attr('height', _height)
      .attr('width', _width)
      .attr('x', (d)-> -(_width/2))
      .attr('y', (d)-> -(_height/2))

    d3.select(@text_handles[0][0])
      .attr('cx', -(_width/2))
      .attr('cy', -(_height/2))

    d3.select(@text_handles[0][1])
      .attr('cx', (_width/2))
      .attr('cy', -(_height/2))

    d3.select(@text_handles[0][2])
      .attr('cx', (_width/2))
      .attr('cy', (_height/2))

    d3.select(@text_handles[0][3])
      .attr('cx', -(_width/2))
      .attr('cy', (_height/2))

  drag_text_handle_end: (d,i) =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = @zoom_helpers.get_coordinates(e)
    
    _width = Math.abs(coordinates.x - @model.get('x')) * 2
    _height = Math.abs(coordinates.y - @model.get('y')) * 2
    
    if @resizing_text
      @text_controls.data()[0].set height: Math.round(_height), width: Math.round(_width)


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
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')' )
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
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')' )
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

    @view.selectAll('g.nodeText').remove()
    @text = d3.select(@el)
      .selectAll('g.nodeText')
      .data(@model.texts.models)

    @text
      .enter()
      .append('svg:g')
        .attr('class', 'nodeText')
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')' )
        .append('svg:text')
          .attr('class', 'artifact')
          .each((d,i)=> d.text_align = 'middle')
          .attr('text-anchor', (d)=> d.text_align)
          .attr('dy', (d)-> d.get('font_size')/3)
          .attr('fill', (d)-> d.get('fill'))
          .attr('fill-opacity', (d)-> d.get('fill_opacity')/100)
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
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
          .each((d,i)=>@set_text(d,i))
          #.text((d)-> d.get('text'))
        
    @text
      .transition()
        .ease('linear')
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')' )
        .selectAll('text.artifact')
          #.text((d)-> d.get('text'))
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
   
    @text
      .exit()
      .remove()


  set_text: (d,i) =>
    words = d.get('text').split(' ')
    return unless words.length > 0

    text_artifact = d3.select(@text[0][i]).selectAll('text.artifact')
    width = d.get('width')
    height = d.get('height')
    font_size = d.get('font_size')
    line_height = d.get('line_height')
    sub_strings = [''] #['This', 'is', 'so', 'cool']
    new_strings = ['']

    @build_line_breaks(text_artifact, d, sub_strings)

    temp = ''
    line = 0
    _.each(words, (word,index)=>
      new_strings[line] = _.clone(sub_strings[line])
      new_strings[line] += String(word + ' ')
      #breaks.data(new_strings).text((d)-> String(d).trim())
      @build_line_breaks(text_artifact, d, new_strings)

      if text_artifact[0][0].getBBox().width < width
        #console.log 'keep going...'
        sub_strings[line] += String(word + ' ')
      
      else
        #console.log '--------------------------- time to wrap -|'
        #console.log text_artifact[0][0].getBBox().width
        #console.log width

        #breaks.data(sub_strings).text((d)-> String(d).trim())
        @build_line_breaks(text_artifact, d, sub_strings)

        sub_strings.push ''
        new_strings[line] = sub_strings[line]
        line = line + 1
        sub_strings[line] += String(word + ' ')

      #console.log sub_strings
      #console.log new_strings
    )


  build_line_breaks: (text_artifact, d, lines) =>
    text_align = d.text_align
    width = d.get('width')
    height = d.get('height')
    font_size = d.get('font_size')
    line_height = d.get('line_height')

    text_artifact.selectAll('tspan.text_substring').remove()
    breaks = text_artifact.selectAll('tspan.text_substring').data(lines)
    breaks
      .enter()
      .append('svg:tspan')
        #.each((d)=> console.log lines.length)
        .attr('class', 'text_substring')
        .attr('x', 0)
        .attr('dx', (d)->
          if text_align is 'start' then return -(width/2)
          else if text_align is 'end' then return (width/2)
          else return 0
        )
        .attr('y', (d,i)->
          -(height/2) + (font_size) * (i+1)
        )
        #.attr('y', (font_size/3))
        .attr('dy', (d,i)=> i * (line_height - font_size))
        .text((d)-> String(d).trim())

    breaks
      .text((d)-> String(d).trim())    

    breaks.exit().remove()
    
    #if text_artifact[0][0].getBBox().height > height
    #  @text_controls?.selectAll('circle.handle').each((d,i)=> console.log i)
    




  # ----------------------------------
  # BUILD Bounding Boxes
  # ----------------------------------
  build_bounding_boxes: ->
    # Remove all existing bounding boxes
    d3.select(@el).select('rect.parent_bounds').remove()
    
    setTimeout =>
      #@build_artifact_bounding_boxes()
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


