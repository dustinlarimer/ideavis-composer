mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-node-text'

module.exports = class DetailNodeTextView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    
    @delegate 'change', 'input, textarea', @update_attributes
    @delegate 'change', 'select', @update_attributes
    @delegate 'click', '.attribute-style button', @update_style
    @delegate 'click', '.attribute-label-align button', @update_align
    @subscribeEvent 'activate_text', @focus_text

  listen:
    'change model': 'update_form'

  render: ->
    super
    if @model.get('text') is ''
      @$('div.label-controls:gt(0)').hide()
    else
      @$('div.label-controls:gt(0)').show()

    @$('#text-attribute-align button[value="' + @model.get('align') + '"]').addClass('active')

  focus_text: =>
    setTimeout (->
      @$('#text-attribute-text').focus().select()
    ), 0

  update_attributes: =>
    _node_text=
      text:           $.trim($("#text-attribute-text").val())
      font_size:      $('#text-attribute-font-size').val().replace(/\D/g,'') or 18
      fill:           $('#text-attribute-fill').val() or 'none'
      fill_opacity:   $('#text-attribute-fill-opacity').val().replace(/\D/g,'') or 100
      stroke_width:   $('#text-attribute-stroke-width').val().replace(/\D/g,'') or 0
      stroke:         $('#text-attribute-stroke').val() or 'none'
      stroke_opacity: $('#text-attribute-stroke-opacity').val().replace(/\D/g,'') or 100
      bold:           $('#text-attribute-style button:eq(0)').val() == 'true' ? true : false
      italic:         $('#text-attribute-style button:eq(1)').val() == 'true' ? true : false
      underline:      $('#text-attribute-style button:eq(2)').val() == 'true' ? true : false
      overline:       $('#text-attribute-style button:eq(3)').val() == 'true' ? true : false
      spacing:        $('#text-attribute-spacing').val().replace(/\D/g,'') or 0
      line_height:    $('#text-attribute-line-height').val().replace(/\D/g,'') or 24
      width:          $('#text-attribute-width').val().replace(/\D/g,'') or 50
      x:              $('#text-attribute-x').val() or 0
      y:              $('#text-attribute-y').val() or 0

    console.log _node_text.x

    if _node_text.text is ''
      @$('div.label-controls:gt(0)').hide()
    else
      @$('div.label-controls:gt(0)').show()

    @model.set _node_text

  update_align: (e) =>
    @model.set align: $(e.currentTarget).val()

  update_style: (e) =>
    _button = $(e.currentTarget)
    _button.val(_button.val() == 'false' ? 'true' : 'false')
    @update_attributes()

  update_form: =>
    $('#text-attribute-width').val(@model.get('width'))
    $('#text-attribute-x').val(@model.get('x'))
    $('#text-attribute-y').val(@model.get('y'))



