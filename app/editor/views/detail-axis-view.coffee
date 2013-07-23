mediator = require 'mediator'
template = require 'editor/views/templates/detail-axis'
View = require 'views/base/view'

module.exports = class DetailAxisView extends View
  autoRender: true
  template: template

  initialize: (data={}) ->
    super
    @delegate 'click', 'input', (e)-> @$(e.target).select()
    @delegate 'click', '.attribute-stroke-linecap button', @update_linecap
    @delegate 'click', '.attribute-label-style button', @modify_style_attribute
    @delegate 'click', '.attribute-label-align button', @update_align
    @delegate 'change', '.axis-attributes input', @update_attributes

  listen:
    'change model': 'update_view'

  render: ->
    super
    @$('.attribute-stroke-linecap button[value="' + @model.get('stroke_linecap') + '"]').addClass('active')
    @$('.attribute-label-align button[value="' + @model.get('label_align') + '"]').addClass('active')
    _.each(@model.get('stroke_dasharray'), (d,i)=>
      @$('.attribute-stroke-dasharray input:eq(' + i + ')').val(d) unless d is 0
    )
    if @model.get('label_text') is ''
      @$('div.label-controls:gt(0)').hide()
    else
      @$('div.label-controls:gt(0)').show()

  modify_style_attribute: (e) =>
    _button = $(e.currentTarget)
    _button.val(_button.val() == 'false' ? 'true' : 'false')
    @update_attributes()

  update_attributes: =>
    _axis=
      x                  : parseInt($('.input-x').val()) or 100
      y                  : parseInt($('.input-y').val()) or 100
      rotate             : parseInt($('.input-rotate').val()) or 0
      stroke_width       : parseInt($('.input-stroke-width').val()) or 0
      stroke             : $('.input-stroke').val()
      stroke_opacity     : $('.input-stroke-opacity').val() or 100
      stroke_dasharray   : []
      label_text         : $('.input-label-text').val()
      label_font_size    : parseInt($('.input-label-font-size').val()) or 12
      label_fill         : $('.input-label-fill').val()
      label_fill_opacity : parseInt($('.input-label-fill-opacity').val()) or 100
      label_bold         : $('.attribute-label-style button:eq(0)').val() == 'true' ? true : false
      label_italic       : $('.attribute-label-style button:eq(1)').val() == 'true' ? true : false
      label_spacing      : parseInt($('.input-label-spacing').val()) or 0
      label_offset_x     : parseInt($('.input-label-offset-x').val())
      label_offset_y     : parseInt($('.input-label-offset-y').val())
    
    if _axis.label_text is ''
      @$('div.label-controls:gt(0)').hide()
    else
      @$('div.label-controls:gt(0)').show()
    
    _.each($('.attribute-stroke-dasharray input'), (d,i)->
      _axis.stroke_dasharray.push parseInt($(d).val()) or 0
    )
    
    @model.save _axis

  update_linecap: (e) =>
    @model.save stroke_linecap: $(e.currentTarget).val()

  update_align: (e) =>
    @model.save label_align: $(e.currentTarget).val()

  update_view: =>
    @$('.input-x').val(@model.get('x'))
    @$('.input-y').val(@model.get('y'))
