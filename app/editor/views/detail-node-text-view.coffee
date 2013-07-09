mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-node-text'

module.exports = class DetailNodeTextView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    
    @delegate 'change', 'input', @update_attributes
    @delegate 'change', 'select', @update_attributes
    @delegate 'click', '.btn-group .btn', @modify_style_attribute

  listen:
    'change model': 'update_form'

  render: ->
    super
    if @model.get('text') is ''
      @$('div.label-controls:gt(0)').hide()
    else
      @$('div.label-controls:gt(0)').show()

  modify_style_attribute: (e) =>
    _button = $(e.currentTarget)
    _button.val(_button.val() == 'false' ? 'true' : 'false')
    @update_attributes()

  update_attributes: =>
    _text = $('#text-attribute-text').val()
    if _text is ''
      @$('div.label-controls:gt(0)').hide()
    else
      @$('div.label-controls:gt(0)').show()
    
    _font_size = $('#text-attribute-font-size').val() or 14
    _fill = $('#text-attribute-fill').val() or 'none'
    _fill_opacity = $('#text-attribute-fill-opacity').val()
    
    _stroke_width = $('#text-attribute-stroke-width').val() or 0
    _stroke = $('#text-attribute-stroke').val() or 'none'
    _stroke_opacity = $('#text-attribute-stroke-opacity').val()
    
    _bold =      $('#text-attribute-style button:eq(0)').val() == 'true' ? true : false
    _italic =    $('#text-attribute-style button:eq(1)').val() == 'true' ? true : false
    _underline = $('#text-attribute-style button:eq(2)').val() == 'true' ? true : false
    _overline =  $('#text-attribute-style button:eq(3)').val() == 'true' ? true : false
    _spacing =   $('#text-attribute-spacing').val() or 0

    _x = $('#text-attribute-x').val() or 0
    _y = $('#text-attribute-y').val() or 0
    _rotate = $('#text-attribute-rotate').val() or 0

    @model.set text: _text, x: _x, y: _y, rotate: _rotate, bold: _bold, italic: _italic, underline: _underline, overline: _overline, spacing: _spacing, font_size: _font_size, fill: _fill, fill_opacity: _fill_opacity, stroke: _stroke, stroke_width: _stroke_width, stroke_opacity: _stroke_opacity

  update_form: =>
    $('#text-attribute-x').val(@model.get('x'))
    $('#text-attribute-y').val(@model.get('y'))



