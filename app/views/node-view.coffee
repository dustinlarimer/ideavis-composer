mediator = require 'mediator'
View = require 'views/base/view'

Text = require 'models/text'

module.exports = class NodeView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super    
    @view = d3.select(@el)
    @padding = 20

    @selected_text = null
    @active_text = null
    @resizing_text = false

    @subscribeEvent 'clear_active', @deactivate
    @listenTo @model, 'sync', @refresh

  render: ->
    super
    @build_paths()
    @build_texts()
    @build_bounding_box()
    console.log '[NodeView Rendered]'

  remove: ->
    @deactivate()
    console.log '[NodeView Removed]'
    super

  refresh: =>
    console.log ' ⟲ Model changed.. refreshing'
    @deactivate_controls()
    @render()
    @build_controls()
    @build_text_handles(@active_text.model, @active_text.index) if @active_text?

  activate: (selected_model) ->
    console.log 'Activating node...'
    @view.classed('active', true)
    @build_controls()
    if selected_model?
      if selected_model instanceof Text
        @selected_text= 
          model: selected_model 
          index: @model.texts.indexOf(selected_model)
        @activate_text(@selected_text.model, @selected_text.index)    

  deactivate: =>
    console.log 'Deactivating node...'
    @view.classed('active', false)
    @deactivate_controls()
    @selected_text = null
    @active_text = null
    @resizing_text = false



  # ----------------------------------
  # ----------------------------------
  # BUILD NODE CONTROL ELEMENTS
  # ----------------------------------
  # ----------------------------------

  build_controls: =>
    #console.log 'Building node controls'
    # SET @TEXT EVENT LISTENERS
    # -------------------------
    @text
      .attr('pointer-events', 'all')
      .call(d3.behavior.drag()
        .on('dragstart', @text_dragstart)
        .on('drag', @text_drag)
        .on('dragend', @text_dragend))

    # CREATE CONTROL ELEMENTS
    # -----------------------
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
        .attr('transform', (d)=> return 'translate('+ @model.get('x') + ',' + @model.get('y') + ') rotate(' + @model.get('rotate') + ')')
    
    @text_controls = @controls.selectAll('g.node_text_controls').data(@model.texts.models)
    @text_controls
      .enter()
      .append('svg:g')
        .attr('class', 'node_text_controls')
        .each((d,i)=> @build_text_bounds(d,i))


  deactivate_controls: =>
    #console.log 'Deactivating node controls'
    # CLEAR @TEXT EVENT LISTENERS
    # ---------------------------
    @text
      .attr('pointer-events', 'none')
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))

    # UNBIND AND REMOVE CONTROL ELEMENTS
    # ----------------------------------
    @origin?.remove()
    @text_bounding_box?.remove()
    @text_handles?.call(
       d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
      .remove()
    @text_controls?.remove()
    @controls?.remove()



  # ----------------------------------
  # ----------------------------------
  # BUILD NODE BOUNDING BOX
  # ----------------------------------
  # ----------------------------------

  build_bounding_box: ->
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
          .attr('height', (d)=> return _parent.height + (@padding*2))
          .attr('width', (d)=> return _parent.width + (@padding*2))
          .attr('x', (d)=> return _parent.x - @padding)
          .attr('y', (d)=> return _parent.y - @padding)
    , 250



  # ----------------------------------
  # ----------------------------------
  # BUILD @TEXT BOUNDING BOX
  # ----------------------------------
  # ----------------------------------

  build_text_bounds: (text_model, index) =>
    #console.log 'build_text_bounds'
    _height = d3.select(@text[0][index])[0][0].getBBox().height + @padding
    _width = text_model.get('width') + @padding
    _x = parseInt(text_model.get('x'))
    _y = parseInt(text_model.get('y'))

    @text_controls.selectAll('rect.bounding_box').remove()
    @text_bounding_box = @text_controls.selectAll('rect.bounding_box').data([text_model])
    @text_bounding_box
      .enter()
      .append('svg:rect')
        .attr('class', 'bounding_box')
        .attr('pointer-events', 'none')
        .attr('x', _x - (_width/2))
        .attr('y', _y - (_height/2))
        .attr('height', _height)
        .attr('width', _width)



  # ----------------------------------
  # ----------------------------------
  # BUILD @TEXT HANDLES
  # ----------------------------------
  # ----------------------------------

  build_text_handles: (text_model, index) =>
    #console.log 'build_text_handles'
    _height = d3.select(@text[0][index])[0][0].getBBox().height + @padding
    _width = text_model.get('width') + @padding
    _x = parseInt(text_model.get('x'))
    _y = parseInt(text_model.get('y'))
    _handle = []
    _handle[0]=
      x: (_x-_width/2), y: (_y-_height/2)
    _handle[1]=
      x: (_x+_width/2), y: (_y-_height/2)

    @text_handles = @text_controls.selectAll('circle.handle').data(_handle)
    @text_handles
      .enter()
      .append('svg:circle')
        .attr('class', 'handle')
        .attr('cx', (d,i)-> d.x)
        .attr('cy', (d,i)-> _y)
        .attr('r', 5)
        .call(d3.behavior.drag()
          .on('dragstart', @drag_text_handle_start)
          .on('drag', @drag_text_handle_move)
          .on('dragend', @drag_text_handle_end))



  # ----------------------------------
  # ----------------------------------
  # @TEXT HANDLES METHODS
  # ----------------------------------
  # ----------------------------------

  drag_text_handle_start: (d,i) =>
    d3.event.sourceEvent.stopPropagation()

  drag_text_handle_move: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    @resizing_text = true
    _x = parseInt(@text_controls.data()[0].get('x'))
    _min_width = 50
    _new_width = Math.abs(_x - d3.event.x) * 2 
    _width  = Math.max(_new_width, _min_width)
    @text_bounding_box
      .attr('width', _width)
      .attr('x', (d)-> _x - (_width/2))
    d3.select(@text_handles[0][0]).attr('cx', _x - (_width/2))
    d3.select(@text_handles[0][1]).attr('cx', _x + (_width/2))

  drag_text_handle_end: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    _x = parseInt(@text_controls.data()[0].get('x'))
    _width = @text_bounding_box.attr('width') - @padding
    if @resizing_text
      @text_controls.data()[0].set width: Math.round(_width)



  # ----------------------------------
  # ----------------------------------
  # @TEXT METHODS
  # ----------------------------------
  # ----------------------------------

  text_dragstart: (d,i) =>
    d3.event.sourceEvent.stopPropagation() if @selected_text?
    if @active_text?
      d.px = d.get('x')
      d.py = d.get('y')

  text_drag: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    if @active_text?
      d.px = Math.round(d3.event.x)
      d.py = Math.round(d3.event.y)
      d3.select(@text[0][i]).attr('transform', 'translate('+ d.px + ',' + d.py + ') rotate(' + d.get('rotate') + ')' )
      d3.select(@text_controls[0][0]).attr('transform', 'translate('+ (d.px - d.get('x')) + ',' + (d.py - d.get('y')) + ')')

  text_dragend: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    if @active_text?
      d.set x: d.px, y: d.py
      @build_bounding_box()

  activate_text: (d, i) =>
    @active_text=
      model: d
      index: i
    @text_controls.each(=> @build_text_handles(d, i))



  # ----------------------------------
  # ----------------------------------
  # BUILD @TEXTs
  # ----------------------------------
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
        .append('svg:text')
          .attr('class', 'artifact')

    @text
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ')')
        .selectAll('text.artifact')
          .each((d,i)=> d.text_align = 'middle')
          .attr('text-anchor', (d)=> d.text_align)
          #.attr('dy', (d)-> d.get('font_size')/3)
          .attr('fill', (d)-> d.get('fill'))
          .attr('fill-opacity', (d)-> d.get('fill_opacity')/100)
          .attr('stroke', (d)-> d.get('stroke'))
          .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
          #.attr('text-rendering', 'optimizeLegibility')
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
      .exit()
      .remove()



  # ----------------------------------
  # ----------------------------------
  # SET @TEXTs CONTENT
  # ----------------------------------
  # ----------------------------------

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
      @build_line_breaks(text_artifact, d, new_strings)
      if text_artifact[0][0].getBBox().width < width
        sub_strings[line] += String(word + ' ')
      else
        sub_strings.push ''
        new_strings[line] = sub_strings[line]
        line = line + 1
        sub_strings[line] += String(word + ' ')
        @build_line_breaks(text_artifact, d, sub_strings)
    )



  # ----------------------------------
  # ----------------------------------
  # BUILD @TEXTs LINE BREAKS
  # ----------------------------------
  # ----------------------------------

  build_line_breaks: (text_artifact, d, lines) =>
    text_align = d.text_align
    width = d.get('width')
    height = d.get('height')
    font_size = d.get('font_size')
    line_height = d.get('line_height')

    #text_artifact.attr('y', -> -1 * (font_size/3) - (line_height * lines.length) / 2)

    text_artifact.selectAll('tspan.text_substring').remove()
    breaks = text_artifact.selectAll('tspan.text_substring').data(lines)
    breaks
      .enter()
      .append('svg:tspan')
        .attr('class', 'text_substring')
        .attr('x', 0)
        .attr('dx', (d)->
          if text_align is 'start' then return -(width/2)
          else if text_align is 'end' then return (width/2)
          else return 0
        )
        #.attr('y', (d,i)=> line_height * i)
        .attr('dy', line_height)
        .text((d)-> String(d).trim())

    breaks
      .text((d)-> String(d).trim())    

    breaks.exit().remove()    

    build_height = d3.select(text_artifact[0][0])[0][0].getBBox().height
    text_artifact.attr('y', => (-line_height + (font_size/3)) - (build_height/2 - (font_size*.6))
      #if lines.length > 1
      #  console.log build_height/lines.length
      #  (-line_height + (font_size/3)) - (build_height/2 - (font_size*.5))
      #  #(font_size/3)
      #  #(font_size*.28) - (build_height/2) - (line_height/2)
      #else
      #  #(font_size/3)
      #  (-line_height + (font_size/3))
      #(-build_height)
    )









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

