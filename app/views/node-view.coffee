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

    @selected_text = null
    @active_text = null
    @resizing_text = false

    @subscribeEvent 'clear_active', @deactivate
    @listenTo @model, 'sync', @refresh

  render: ->
    super
    @build_paths()
    @build_texts()
    @build_bounding_boxes()
    console.log '[NodeView Rendered]'

  remove: ->
    @deactivate()
    console.log '[NodeView Removed]'
    super

  refresh: =>
    console.log 'Model changed.. refreshing'
    @deactivate_controls()
    @render()
    @build_controls()
    @build_text_handles(@active_text) if @active_text?

  activate: ->
    console.log 'Activating node...'
    @view.classed('active', true)
    @build_controls()
    
    #@text
    #  .attr('pointer-events', 'all')
    #  .attr('class', 'needsclick')
    #  .call(d3.behavior.drag()
    #    .on('dragstart', @text_dragstart)
    #    .on('drag', @text_drag)
    #    .on('dragend', @text_dragend))

  deactivate: =>
    console.log 'Deactivating node...'
    @view.classed('active', false)
    
    #@text
    #  .attr('pointer-events', 'none')
    #  .attr('class', null)
    #  .call(d3.behavior.drag()
    #    .on('dragstart', null)
    #    .on('drag', null)
    #    .on('dragend', null))

    @deactivate_controls()

    @selected_text = null
    @active_text = null
    @resizing_text = false



  # ----------------------------------
  # NODE CONTROLS
  # ----------------------------------

  build_controls: =>
    console.log 'Building node controls'

    # SET @TEXT EVENT LISTENERS
    @text
      .attr('pointer-events', 'all')
      #.attr('class', 'needsclick')
      .call(d3.behavior.drag()
        .on('dragstart', @text_dragstart)
        .on('drag', @text_drag)
        .on('dragend', @text_dragend))

    @view.select('path.origin').remove()
    @origin = @view.selectAll('path.origin').data([{}])
    @origin
      .enter()
      .insert('path', 'g.nodeText')
        .attr('class', 'origin')
        .attr('shape-rendering', 'crispEdges')
        .attr('fill', 'none')
        .attr('d', 'M 0,-12 L 0,12 M -12,0 L 12,0')
        .style('stroke-dasharray', '4,1')
    
    mediator.controls.selectAll('g#node_controls').remove()
    @controls = mediator.controls
      .append('svg:g')
        .attr('id', 'node_controls')
    
    @text_controls = @controls.selectAll('g.node_text_controls').data(@model.texts.models)
    @text_controls
      .enter()
      .append('svg:g')
        .attr('class', 'node_text_controls')
        .attr('transform', (d)=> return 'translate('+ @model.get('x') + ',' + @model.get('y') + ') rotate(' + (parseInt(d.get('rotate')) + parseInt(@model.get('rotate'))) + ')')
        .each((d)=> @build_text_bounds(d))


  deactivate_controls: =>
    console.log 'Deactivating node controls'

    # CLEAR @TEXT EVENT LISTENERS
    @text
      .attr('pointer-events', 'none')
      #.attr('class', null)
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))

    @origin?.remove()
    @text_bounding_box?.transition().duration(250).attr('stroke-opacity', 0).remove()
    @text_handles?.call(
       d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
      .transition().duration(250).attr('fill-opacity', 0).remove()
    @text_controls?.transition().duration(250).remove()
    @controls?.transition().duration(250).remove()



  # ----------------------------------
  # @TEXT CONTROLS
  # ----------------------------------

  text_dragstart: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    console.log 'text_dragstart'
    @selected_text = d
    if @active_text?
      d.px = d.get('x')
      d.py = d.get('y')

  text_drag: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    console.log 'text_drag'
    @selected_text = null
    if @active_text?
      d.px = Math.round(d3.event.x)
      d.py = Math.round(d3.event.y)
      d3.select(@text[0][i]).attr('transform', 'translate('+ d.px + ',' + d.py + ') rotate(' + d.get('rotate') + ')' )
      _x = @model.get('x') + d.px - d.get('x')
      _y = @model.get('y') + d.py - d.get('y')
      _rotate = parseInt(d.get('rotate')) + parseInt(@model.get('rotate'))
      d3.select(@text_controls[0][0]).attr('transform', 'translate('+ _x + ',' + _y + ') rotate(' + _rotate + ')')


  text_dragend: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    console.log 'text_dragend'
    if @selected_text
      @activate_text(d)
    else if @active_text? and d.px isnt d.get('x')
      #console.log 'active text dragged'
      d.set x: d.px, y: d.py
      @build_bounding_boxes()

  activate_text: (text) =>
    console.log text
    @active_text = text
    @text_controls.each((text)=> @build_text_handles(text))




  # ----------------------------------
  # BUILD @TEXT HANDLES
  # ----------------------------------

  build_text_bounds: (text_model) =>
    console.log 'build_text_bounds'
    _height = text_model.get('height')
    _width = text_model.get('width')
    _x = parseInt(text_model.get('x'))
    _y = parseInt(text_model.get('y'))

    @text_controls.selectAll('rect.bounding_box').remove()
    @text_bounding_box = @text_controls.selectAll('rect.bounding_box').data([text_model])
    @text_bounding_box
      .enter()
      .append('svg:rect')
        .attr('class', 'bounding_box')
        .attr('pointer-events', 'none')
        .attr('x', (d)-> d.get('x') - (d.get('width')/2))
        .attr('y', (d)-> d.get('y') - (d.get('height')/2))
        .attr('height', (d)-> d.get('height'))
        .attr('width', (d)-> d.get('width'))
        .attr('fill', 'none')
        .attr('stroke', '#000')
        .attr('stroke-dasharray', '5,3')
        .attr('stroke-opacity', .2)


  build_text_handles: (text_model) =>
    console.log 'build_text_handles'
    _height = text_model.get('height')
    _width = text_model.get('width')
    _x = parseInt(text_model.get('x'))
    _y = parseInt(text_model.get('y'))
    _handle = []
    _handle[0]=
      x: (_x-_width/2), y: (_y-_height/2)
    _handle[1]=
      x: (_x+_width/2), y: (_y-_height/2)
    _handle[2]=
      x: (_x+_width/2), y: (_y+_height/2)
    _handle[3]=
      x: (_x-_width/2), y: (_y+_height/2)

    @text_handles = @text_controls.selectAll('circle.handle').data(_handle)
    @text_handles
      .enter()
      .append('svg:circle')
        .attr('class', 'handle')
        .attr('cx', (d,i)-> d.x)
        .attr('cy', (d,i)-> d.y)
        .attr('r', 5)
        .attr('fill', '#757575')   
        .attr('fill-opacity', .5)
        .attr('cursor', 'move') 
        .call(d3.behavior.drag()
          .on('dragstart', @drag_text_handle_start)
          .on('drag', @drag_text_handle_move)
          .on('dragend', @drag_text_handle_end))
        #.transition()
        #  .ease('linear')
        #  .duration(250)
        #  .attr('fill-opacity', .5)


  drag_text_handle_start: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    console.log 'startz!'

  drag_text_handle_move: (d,i) =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = @zoom_helpers.get_coordinates(e)

    @resizing_text = true
    _x = parseInt(@text_controls.data()[0].get('x'))
    _y = parseInt(@text_controls.data()[0].get('y'))

    _min_height = @text_controls.data()[0].get('font_size')
    _drag_height = Math.abs(coordinates.y - @model.get('y') - _y) * 2

    _min_width = 50
    _drag_width = Math.abs(coordinates.x - @model.get('x') - _x) * 2

    _height = Math.max(_drag_height, _min_height)
    _width  = Math.max(_drag_width, _min_width)

    #console.log Math.round(_height) + 'px by ' + Math.round(_width) + 'px'

    @text_bounding_box
      .attr('height', _height)
      .attr('width', _width)
      .attr('x', (d)-> _x - (_width/2))
      .attr('y', (d)-> _y - (_height/2))

    d3.select(@text_handles[0][0])
      .attr('cx', _x - (_width/2))
      .attr('cy', _y - (_height/2))

    d3.select(@text_handles[0][1])
      .attr('cx', _x + (_width/2))
      .attr('cy', _y - (_height/2))

    d3.select(@text_handles[0][2])
      .attr('cx', _x + (_width/2))
      .attr('cy', _y + (_height/2))

    d3.select(@text_handles[0][3])
      .attr('cx', _x - (_width/2))
      .attr('cy', _y + (_height/2))

  drag_text_handle_end: (d,i) =>
    e = d3.event.sourceEvent
    e.stopPropagation()
    coordinates = @zoom_helpers.get_coordinates(e)

    _x = parseInt(@text_controls.data()[0].get('x'))
    _y = parseInt(@text_controls.data()[0].get('y'))
    _width = Math.abs(coordinates.x - @model.get('x') - _x) * 2
    _height = Math.abs(coordinates.y - @model.get('y') - _y) * 2
    
    if @resizing_text
      @text_controls.data()[0].set height: Math.round(_height), width: Math.round(_width)


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
        #.attr('pointer-events', 'none')
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










  # ----------------------------------
  # SCRAP?
  # ----------------------------------


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

