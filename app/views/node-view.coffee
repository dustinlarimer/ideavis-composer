mediator = require 'mediator'
View = require 'views/base/view'

Path = require 'models/path'
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

    @selected_path = null
    @active_path = null
    @resizing_path = false

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
    @build_path_handles(@active_path.model, @active_path.index) if @active_path?

  activate: (selected_model) ->
    console.log 'Activating node...'
    @view.classed('active', true)
    @build_controls()

    if selected_model?

      if selected_model instanceof Path
        @selected_path=
          model: selected_model
          index: @model.paths.indexOf(selected_model)
        @activate_path(@selected_path.model, @selected_path.index)

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

    @selected_path = null
    @active_path = null
    @resizing_path = false


  rebuild: =>
    console.log 'Rebuilding node...'
    @deactivate()
    @text.remove()
    @path.remove()
    @refresh()



  # ----------------------------------
  # ----------------------------------
  # BUILD NODE CONTROL ELEMENTS
  # ----------------------------------
  # ----------------------------------

  build_controls: =>

    # SET @TEXT EVENT LISTENERS
    # -------------------------
    @text
      .call(d3.behavior.drag()
        .on('dragstart', @text_dragstart)
        .on('drag', @text_drag)
        .on('dragend', @text_dragend))
      #.on('dblclick', @text_inline_edit)

    # SET @PATH EVENT LISTENERS
    # -------------------------
    @path
      # DISABLED
      #.call(d3.behavior.drag()
      #  .on('dragstart', @path_dragstart)
      #  .on('drag', @path_drag)
      #  .on('dragend', @path_dragend))


    # CREATE CONTROL ELEMENTS
    # -----------------------
    @view.select('path.origin').remove()
    @origin = @view.selectAll('path.origin').data([{}])
    @origin
      .enter()
      .insert('path', 'g.nodeText')
        .attr('class', 'origin')
        .attr('pointer-events', 'none')
        .attr('fill', 'none')
        .attr('d', 'M 0,-12 L 0,12 M -12,0 L 12,0')
        .style('stroke-dasharray', '4,1')
    
    #mediator.controls.selectAll('g#node_controls').remove()
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

    @path_controls = @controls.selectAll('g.node_path_controls').data(@model.paths.models)
    @path_controls
      .enter()
      .append('svg:g')
        .attr('class', 'node_path_controls')
        .attr('transform', (d,i)-> 'rotate(' + d.get('rotate') + ')')
        .each((d,i)=> @build_path_bounds(d,i))


  deactivate_controls: =>

    # CLEAR @TEXT EVENT LISTENERS
    # ---------------------------
    @text
      .call(d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))

    # CLEAR @PATH EVENT LISTENERS
    # ---------------------------
    @path
      # DISABLED
      #.call(d3.behavior.drag()
      #  .on('dragstart', null)
      #  .on('drag', null)
      #  .on('dragend', null))

    # UNBIND AND REMOVE CONTROL ELEMENTS
    # ----------------------------------
    @text_bounding_box?.remove()
    @text_handles?.call(
       d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
      .remove()
    @text_controls?.remove()
    
    @path_bounding_box?.remove()
    @path_handles?.call(
       d3.behavior.drag()
        .on('dragstart', null)
        .on('drag', null)
        .on('dragend', null))
      .remove()
    @path_controls?.remove()
    
    @origin?.remove()    
    @controls?.remove()



  # ----------------------------------
  # ----------------------------------
  # BUILD NODE BOUNDING BOX
  # ----------------------------------
  # ----------------------------------

  build_bounding_box: ->
    # Remove all existing bounding boxes
    @view.select('rect.parent_bounds').remove()
    setTimeout =>
      _parent = @view[0][0].getBBox()
      @view
        .selectAll('rect.parent_bounds')
        .data([{}])
        .enter()
        .insert('rect', 'g.nodePath')
          .attr('class', 'parent_bounds')
          .attr('fill', 'none')
          .attr('height', (d)=> return _parent.height + (@padding))
          .attr('width', (d)=> return _parent.width + (@padding))
          .attr('x', (d)=> return _parent.x - (@padding/2))
          .attr('y', (d)=> return _parent.y - (@padding/2))
    , 250



  # ----------------------------------
  # ----------------------------------
  # BUILD @TEXT BOUNDING BOX
  # ----------------------------------
  # ----------------------------------

  build_text_bounds: (text_model, index) =>
    #console.log 'build_text_bounds'
    _height = d3.select(@text[0][index])[0][0].getBBox().height
    _width = parseInt(text_model.get('width'))
    _x = parseInt(text_model.get('x'))
    _y = parseInt(text_model.get('y'))

    @text_controls.selectAll('rect.bounding_box').remove()
    @text_bounding_box = @text_controls.selectAll('rect.bounding_box').data([text_model])
    @text_bounding_box
      .enter()
      .append('svg:rect')
        .attr('class', 'bounding_box')
        .attr('pointer-events', 'none')
        .attr('fill', 'none')
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
    _height = d3.select(@text[0][index])[0][0].getBBox().height
    _width = parseInt(text_model.get('width'))
    _x = parseInt(text_model.get('x'))
    _y = parseInt(text_model.get('y'))
    _handle = []
    _handle[0]=
      x: (_x-_width/2), y: (_y-_height/2)
    _handle[1]=
      x: (_x+_width/2), y: (_y-_height/2)

    @text_controls.select('rect').attr('class', 'bounding_box active')
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
    _width = @text_bounding_box.attr('width')
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

      d.px = 0 if (d.px > -7 and d.px < 7)
      d.py = 0 if (d.py > -7 and d.py < 7)

      d3.select(@text[0][i]).attr('transform', 'translate('+ d.px + ',' + d.py + ')')
      d3.select(@text_controls[0][0]).attr('transform', 'translate('+ (d.px - d.get('x')) + ',' + (d.py - d.get('y')) + ')')

  text_dragend: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    if @active_text?
      d.set x: d.px, y: d.py
      #@build_bounding_box()

  text_inline_edit: (d,i) =>
    d3.event.stopPropagation() if typeof SVGForeignObjectElement isnt 'undefined' #bypass if !support
    _placement = d3.select(@text_controls[0][i])[0][0].getBoundingClientRect()
    _model = @model.texts.models[i]
    d3.select('#stage')
      .append('textarea')
        .attr('id', 'editable_node_label')
        .html(_model.get('text'))
        .style('background', '#fff')
        .style('text-align', -> 
          _align = _model.get('align')
          'center' if _align is 'middle'
          'left' if _align is 'start'
          'right' if _align is 'end'
        )
        .style('height', _placement.height + 'px')
        .style('left', _placement.left + 5 + 'px')
        .style('top', _placement.top + 'px')
        .style('width', _model.get('width') + 'px')

  activate_text: (d, i) =>
    @active_text=
      model: d
      index: i
    @text_controls.each(=> @build_text_handles(d, i))
    setTimeout => @publishEvent 'activate_text', 0




  # ----------------------------------
  # ----------------------------------
  # BUILD @TEXTs
  # ----------------------------------
  # ----------------------------------

  build_texts: ->

    @text = @view.selectAll('g.nodeText').data(@model.texts.models)
    @text.enter()
      .append('svg:g').attr('class', 'nodeText')
        .append('svg:g').attr('class', 'paragraph')

    @text
        .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ')')
        .selectAll('g.paragraph')
          .attr('fill', (d,i)-> d.get('fill'))
          .attr('fill-opacity', (d,i)-> d.get('fill_opacity')/100)
          .attr('stroke', (d,i)-> d.get('stroke'))
          .attr('stroke-opacity', (d,i)-> d.get('stroke_opacity')/100)
          .attr('font-family', 'Helvetica, sans-serif')
          .attr('font-size', (d,i)-> d.get('font_size'))
          .attr('font-style',(d,i)-> if d.get('italic') then return 'italic' else return 'normal')
          .attr('font-weight', (d,i)-> if d.get('bold') then return 'bold' else return 'normal')
          .attr('text-decoration', (d,i)->
            _deco = []
            if d.get('underline') then _deco.push('underline')
            if d.get('overline') then _deco.push('overline')
            return _deco.join(' ')
          )
          .attr('letter-spacing', (d,i)-> d.get('spacing'))
          .attr('stroke-width', (d,i)-> d.get('stroke_width'))
          .each((d,i)=> @set_text(d,i))
   
    @text.exit().remove()



  # ----------------------------------
  # ----------------------------------
  # SET @TEXTs CONTENT
  # ----------------------------------
  # ----------------------------------

  set_text: (d,i) =>
    words = d.get('text').split(' ')
    return unless words.length > 0

    text_artifact = d3.select(@text[0][i]).selectAll('g.paragraph')
    width = parseInt(d.get('width'))
    sub_strings = ['']
    new_strings = ['']
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
    font_size = d.get('font_size')
    line_height = d.get('line_height')
    text_align = d.get('align')
    width = d.get('width')

    text_artifact.selectAll('text.artifact').remove()
    paragraph_lines = text_artifact.selectAll('text.artifact').data(lines)
    paragraph_lines.enter().append('svg:text').attr('class', 'artifact')
    paragraph_lines
        .attr('text-anchor', text_align)
        .attr('x', =>
          if text_align is 'start' then return -(width/2)
          else if text_align is 'end' then return (width/2)
          else return 0
        )
        .attr('y', (d,i)=> line_height*i)
        .text((d)-> String(d).trim())

    text_artifact.attr('transform', =>
      return 'translate(0,' + ((-line_height * (lines.length-1))/2 + (font_size*.3)) + ')'
    )














  # ----------------------------------
  # ----------------------------------
  # BUILD @PATH BOUNDING BOX
  # ----------------------------------
  # ----------------------------------

  build_path_bounds: (path_model, index) =>
    _height = parseInt(path_model.get('height'))
    _width = parseInt(path_model.get('width'))
    _x = parseInt(path_model.get('x'))
    _y = parseInt(path_model.get('y'))

    @path_controls.selectAll('rect.bounding_box').remove()
    @path_bounding_box = @path_controls.selectAll('rect.bounding_box').data([path_model])
    @path_bounding_box
      .enter()
      .append('svg:rect')
        .attr('class', 'bounding_box')
        .attr('pointer-events', 'none')
        .attr('fill', 'none')
        .attr('x', _x - (_width/2))
        .attr('y', _y - (_height/2))
        .attr('height', _height)
        .attr('width', _width)


  # ----------------------------------
  # ----------------------------------
  # BUILD @PATH HANDLES
  # ----------------------------------
  # ----------------------------------

  build_path_handles: (path_model, index) =>
    _height = parseInt(path_model.get('height'))
    _width = parseInt(path_model.get('width'))
    _x = parseInt(path_model.get('x'))
    _y = parseInt(path_model.get('y'))
    _handle = []
    _handle[0]=
      x: (_x-_width/2), y: (_y-_height/2)
    _handle[1]=
      x: (_x+_width/2), y: (_y-_height/2)
    _handle[2]=
      x: (_x+_width/2), y: (_y+_height/2)
    _handle[3]=
      x: (_x-_width/2), y: (_y+_height/2)

    @path_controls.select('rect').attr('class', 'bounding_box active')
    @path_handles = @path_controls.selectAll('circle.handle').data(_handle)
    @path_handles
      .enter()
      .append('svg:circle')
        .attr('class', 'handle')
        .attr('cx', (d,i)-> d.x)
        .attr('cy', (d,i)-> d.y)
        .attr('r', 5)
        .call(d3.behavior.drag()
          .on('dragstart', @drag_path_handle_start)
          .on('drag', @drag_path_handle_move)
          .on('dragend', @drag_path_handle_end))



  # ----------------------------------
  # ----------------------------------
  # @PATH HANDLES METHODS
  # ----------------------------------
  # ----------------------------------

  drag_path_handle_start: (d,i) =>
    d3.event.sourceEvent.stopPropagation()

  drag_path_handle_move: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    @resizing_path = true

    _h = parseInt(@path_controls.data()[0].get('height'))
    _w = parseInt(@path_controls.data()[0].get('width'))
    _x = parseInt(@path_controls.data()[0].get('x'))
    _y = parseInt(@path_controls.data()[0].get('y'))

    _new_height = Math.abs(_y - d3.event.y) * 2
    if key.shift
      _new_width = _w * (_new_height / _h)
    else
      _new_width = Math.abs(_x - d3.event.x) * 2 

    _height  = Math.max(_new_height, 20)
    _width  = Math.max(_new_width, 20)

    @path_bounding_box
      .attr('height', _height)
      .attr('width', _width)
      .attr('x', (d)-> (_x-_width/2))
      .attr('y', (d)-> (_y-_height/2))

    d3.select(@path_handles[0][0])
      .attr('cx', (_x-_width/2))
      .attr('cy', (_y-_height/2))

    d3.select(@path_handles[0][1])
      .attr('cx', (_x+_width/2))
      .attr('cy', (_y-_height/2))

    d3.select(@path_handles[0][2])
      .attr('cx', (_x+_width/2))
      .attr('cy', (_y+_height/2))

    d3.select(@path_handles[0][3])
      .attr('cx', (_x-_width/2))
      .attr('cy', (_y+_height/2))

  drag_path_handle_end: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    _x = parseInt(@path_controls.data()[0].get('x'))
    _y = parseInt(@path_controls.data()[0].get('y'))
    _height = @path_bounding_box.attr('height')
    _width = @path_bounding_box.attr('width')
    if @resizing_path
      @path_controls.data()[0].set height: Math.round(_height), width: Math.round(_width)




  # ----------------------------------
  # ----------------------------------
  # @PATH METHODS
  # ----------------------------------
  # ----------------------------------

  path_dragstart: (d,i) =>
    d3.event.sourceEvent.stopPropagation() if @selected_path?
    if @active_path?
      d.px = d.get('x')
      d.py = d.get('y')

  path_drag: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    if @active_path?
      d.px = Math.round(d3.event.x)
      d.py = Math.round(d3.event.y)
      d3.select(@path[0][i]).attr('transform', 'translate('+ d.px + ',' + d.py + ') rotate(' + d.get('rotate') + ')')
      d3.select(@path_controls[0][0]).attr('transform', 'translate('+ (d.px - d.get('x')) + ',' + (d.py - d.get('y')) + ')')

  path_dragend: (d,i) =>
    d3.event.sourceEvent.stopPropagation()
    if @active_path?
      d.set x: d.px, y: d.py
      #@build_bounding_box()

  activate_path: (d, i) =>
    @active_path=
      model: d
      index: i
    @path_controls.each(=> @build_path_handles(d, i))
    setTimeout => @publishEvent 'activate_path', 0



  # ----------------------------------
  # BUILD @Paths
  # ----------------------------------
  build_paths: =>
    #@view.selectAll('g.nodePath').remove()

    @path = @view.selectAll('g.nodePath').data(@model.paths.models)
    @path
      .enter()
      .append('svg:g')
        .attr('class', 'nodePath')
        .append('svg:path')
          .attr('class', 'artifact')

    @path
      .attr('transform', (d)-> return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')' )
      .selectAll('path.artifact')
        .each((d,i)=> @generate_shape(d))
        .attr('d', (d)-> d.path)
        .attr('fill', (d)-> d.get('fill'))
        .attr('fill-opacity', (d)-> d.get('fill_opacity')/100)
        .attr('stroke', (d)-> if d.get('shape') is 'none' then return 'none' else return d.get('stroke'))
        .attr('stroke-dasharray', (d)-> d.get('stroke_dasharray').join())
        .attr('stroke-linecap', (d)-> d.get('stroke_linecap'))
        .attr('stroke-linejoin', (d)-> 
          _linecap = d.get('stroke_linecap')
          if _linecap is 'square' then return 'miter' else if _linecap is 'butt' then return 'bevel' else return _linecap
        )
        .attr('stroke-opacity', (d)-> d.get('stroke_opacity')/100)
        .attr('stroke-width', (d)-> d.get('stroke_width'))
    
    @path
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
