mediator = require 'mediator'
template = require 'editor/views/templates/detail-link'
View = require 'views/base/view'

DetailLinkMarkerStartView = require 'editor/views/detail-link-marker-start-view'
DetailLinkMarkerEndView = require 'editor/views/detail-link-marker-end-view'

module.exports = class DetailLinkView extends View
  autoRender: true
  template: template
  regions:
    '#marker-start': 'marker_start'
    '#marker-end': 'marker_end'

  initialize: (data={}) ->
    super
    @delegate 'change', '#link-baseline input', @update_attributes
    @delegate 'change', '#link-label input', @update_attributes
    @delegate 'click', 'input', (e)-> @$(e.target).select()
    @delegate 'click', '#baseline-attribute-interpolation button', @update_interpolation
    @delegate 'click', '#baseline-attribute-stroke-linecap button', @update_linecap
    @delegate 'click', '#label-attribute-style button', @modify_style_attribute
    @delegate 'click', '#label-attribute-align button', @update_align

  render: ->
    super
    @subview 'marker-start-view', new DetailLinkMarkerStartView model: @model.marker_start, region: 'marker_start'
    @subview 'marker-end-view', new DetailLinkMarkerEndView model: @model.marker_end, region: 'marker_end'
    
    @$('#baseline-attribute-interpolation button[value="' + @model.get('interpolation') + '"]').addClass('active')
    @$('#label-attribute-align button[value="' + @model.get('label_align') + '"]').addClass('active')
    @$('#baseline-attribute-stroke-linecap button[value="' + @model.get('stroke_linecap') + '"]').addClass('active')
    _.each(@model.get('stroke_dasharray'), (d,i)=>
      @$('#baseline-attribute-stroke-dasharray input:eq(' + i + ')').val(d) unless d is 0
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
    _stroke_width = parseInt($('#baseline-attribute-stroke-width').val()) or 0
    _stroke = $('#baseline-attribute-stroke').val()
    _stroke_opacity = $('#baseline-attribute-stroke-opacity').val() or 100

    _stroke_dash = []
    _.each($('#baseline-attribute-stroke-dasharray input'), (d,i)->
      _stroke_dash.push parseInt($(d).val()) or 0
    )
    _fill = $('#baseline-attribute-fill').val() or 'none'

    _label_text = $('#label-attribute-text').val()
    if _label_text is ''
      @$('div.label-controls:gt(0)').hide()
    else
      @$('div.label-controls:gt(0)').show()

    _label_font_size = parseInt($('#label-attribute-font-size').val()) or 12
    _label_fill = $('#label-attribute-fill').val()
    _label_fill_opacity = parseInt($('#label-attribute-fill-opacity').val()) or 100

    _label_bold = $('#label-attribute-style button:eq(0)').val() == 'true' ? true : false
    _label_italic = $('#label-attribute-style button:eq(1)').val() == 'true' ? true : false

    _label_offset_x = parseInt($('#label-attribute-x').val()) or 0
    _label_offset_y = parseInt($('#label-attribute-y').val()) or 0
    _label_spacing = parseInt($('#label-attribute-spacing').val()) or 0

    @model.save stroke_width: _stroke_width, stroke: _stroke, stroke_opacity: _stroke_opacity, stroke_dasharray: _stroke_dash, label_text: _label_text, label_font_size: _label_font_size, label_fill: _label_fill, label_fill_opacity: _label_fill_opacity, label_bold: _label_bold, label_italic: _label_italic, label_offset_x: _label_offset_x, label_offset_y: _label_offset_y, label_spacing: _label_spacing, fill: _fill

  update_interpolation: (e) =>
    @model.save interpolation: $(e.currentTarget).val()
    mediator.publish 'refresh_canvas'

  update_linecap: (e) =>
    @model.save stroke_linecap: $(e.currentTarget).val()

  update_align: (e) =>
    @model.save label_align: $(e.currentTarget).val()
    mediator.publish 'refresh_canvas'

