mediator = require 'mediator'
template = require 'editor/views/templates/detail-link'
View = require 'views/base/view'

DetailLinkMarkerStartView = require 'editor/views/detail-link-marker-start-view'
DetailLinkMarkerEndView = require 'editor/views/detail-link-marker-end-view'

module.exports = class DetailLinkView extends View
  autoRender: true
  template: template
  id: 'baseline-attributes'
  regions:
    '#marker-start': 'marker_start'
    '#marker-end': 'marker_end'

  initialize: (data={}) ->
    super
    @delegate 'click', 'input', (e)-> @$(e.target).select()
    @delegate 'change', '.baseline-controls input', @update_attributes
    @delegate 'change', '.label-controls input', @update_attributes
    @delegate 'click', '#baseline-attribute-curve button', @update_curve
    @delegate 'click', '#baseline-attribute-stroke-linecap button', @update_linecap
    @delegate 'click', '#label-attribute-style button', @update_style
    @delegate 'click', '#label-attribute-align button', @update_align

  render: ->
    super
    @subview 'marker-start-view', new DetailLinkMarkerStartView model: @model.marker_start, region: 'marker_start'
    @subview 'marker-end-view', new DetailLinkMarkerEndView model: @model.marker_end, region: 'marker_end'
    
    @$('#baseline-attribute-curve button[value="' + @model.get('interpolation') + '"]').addClass('active')
    @$('a > span[id^="icon-curve-"]').attr('id', 'icon-curve-' + @model.get('interpolation'))

    @$('#label-attribute-align button[value="' + @model.get('label_align') + '"]').addClass('active')

    _.each(@model.get('stroke_dasharray'), (d,i)=>
      @$('#baseline-attribute-stroke-dasharray input:eq(' + i + ')').val(d) unless d is 0
    )
    @$('#baseline-attribute-stroke-linecap button[value="' + @model.get('stroke_linecap') + '"]').addClass('active')

    if @model.get('label_text') is ''
      @$('div.label-controls:gt(0)').hide()
    else
      @$('div.label-controls:gt(0)').show()


  update_attributes: (e) =>
    _link=
      stroke_width:       parseInt($('#baseline-attribute-stroke-width').val()) or 0
      stroke:             $('#baseline-attribute-stroke').val()
      stroke_opacity:     $('#baseline-attribute-stroke-opacity').val() or 100
      stroke_dasharray:   []
      fill:               $('#baseline-attribute-fill').val() or 'none'
      label_text:         $('#label-attribute-text').val()
      label_font_size:    parseInt($('#label-attribute-font-size').val()) or 12
      label_fill:         $('#label-attribute-fill').val()
      label_fill_opacity: parseInt($('#label-attribute-fill-opacity').val()) or 100
      label_bold:         $('#label-attribute-style button:eq(0)').val() == 'true' ? true : false
      label_italic:       $('#label-attribute-style button:eq(1)').val() == 'true' ? true : false
      label_offset_x:     parseInt($('#label-attribute-x').val()) or 0
      label_offset_y:     parseInt($('#label-attribute-y').val()) or 0
      label_spacing:      parseInt($('#label-attribute-spacing').val()) or 0

    _.each($('#baseline-attribute-stroke-dasharray input'), (d,i)->
      _link.stroke_dasharray.push parseInt($(d).val()) or 0
    )

    if _link.label_text is ''
      @$('div.label-controls:gt(0)').hide()
    else
      @$('div.label-controls:gt(0)').show()
    @model.save _link


  update_align: (e) =>
    @model.save label_align: $(e.currentTarget).val()

  update_curve: (e) =>
    _interpolation = $(e.currentTarget).val()
    @$('a > span[id^="icon-curve-"]').attr('id', 'icon-curve-' + _interpolation)
    @model.save interpolation: _interpolation

  update_linecap: (e) =>
    @model.save stroke_linecap: $(e.currentTarget).val()

  update_style: (e) =>
    _button = $(e.currentTarget)
    _button.val(_button.val() == 'false' ? 'true' : 'false')
    @update_attributes()

