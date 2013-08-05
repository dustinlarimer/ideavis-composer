mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-node-path'

module.exports = class DetailNodePathView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    @delegate 'change', 'input', @update_attributes
    #@delegate 'change', '#path-attribute-stroke-dasharray', @update_attributes
    @delegate 'click', '#path-attribute-shape button', @update_shape
    @delegate 'click', '#path-attribute-stroke-linecap button', @update_linecap
    @delegate 'click', 'a.fill-image', -> return false

  render: ->
    super
    #@$('#path-attribute-scale').val(@model.get('scale')*100)
    @$('a > span[id^="icon-shape-"]').attr('id', 'icon-shape-'+@model.get('shape')).html(@model.get('shape'))
    @$('#path-attribute-shape button[value="' + @model.get('shape') + '"]').addClass('active')
    if @model.get('shape') is 'none'
      @$('input, button', 'div.shape-controls:gt(0)').prop('disabled', true)
    else
      @$('input, button', 'div.shape-controls:gt(0)').prop('disabled', false)
    @$('#path-attribute-shape button').prop('disabled', false)
    
    _.each(@model.get('stroke_dasharray'), (d,i)=>
      @$('#path-attribute-stroke-dasharray input:eq(' + i + ')').val(d) unless d is 0
    )
    @$('#path-attribute-stroke-linecap button[value="' + @model.get('stroke_linecap') + '"]').addClass('active')
    @$('a.fill-image').tooltip({placement: 'top'})

  update_attributes: =>
    _path=
      height: $('#path-attribute-height').val() or 100
      width:  $('#path-attribute-width').val() or 100
      rotate: $('#path-attribute-rotate').val() or 0
      fill:   $('#path-attribute-fill').val() or 'none'
      fill_opacity: $('#path-attribute-fill-opacity').val() or 100
      stroke: $('#path-attribute-stroke').val() or 'none'
      stroke_width: $('#path-attribute-stroke-width').val() or 0
      stroke_opacity: $('#path-attribute-stroke-opacity').val() or 100
      stroke_dash: []
    
    _.each($('#path-attribute-stroke-dasharray input'), (d,i)->
      _path.stroke_dash.push parseInt($(d).val()) or 0
    )

    @model.set _path

  update_shape: (e) =>
    _shape = $(e.currentTarget).val()
    @$('a > span[id^="icon-shape-"]').attr('id', 'icon-shape-'+_shape).html(_shape)
    if _shape is 'none'
      @$('input, button', 'div.shape-controls:gt(0)').prop('disabled', true)
    else
      @$('input, button', 'div.shape-controls:gt(0)').prop('disabled', false)
    @$('#path-attribute-shape button').prop('disabled', false)
    @$('.dropdown').removeClass('open')
    @model.set shape: _shape

  update_linecap: (e) =>
    _linecap = $(e.currentTarget).val()
    @model.set stroke_linecap: _linecap


