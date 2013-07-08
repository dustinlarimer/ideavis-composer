mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-node-path'

module.exports = class DetailNodePathView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    @delegate 'change', 'input', @update_attributes
    @delegate 'click', '#path-attribute-shape button', @update_shape
    @delegate 'click', '#path-attribute-stroke-linecap button', @update_linecap

  render: ->
    super
    @$('#path-attribute-shape button[value="' + @model.get('shape') + '"]').addClass('active')
    @$('#path-attribute-stroke-linecap button[value="' + @model.get('stroke_linecap') + '"]').addClass('active')

  update_attributes: =>
    console.log 'path:update_attributes'
    _x = $('#path-attribute-x').val() or 0
    _y = $('#path-attribute-y').val() or 0
    _rotate = $('#path-attribute-rotate').val() or 0
    _scale = $('#path-attribute-scale').val() or 1
    _fill = $('#path-attribute-fill').val() or 'none'
    _fill_opacity = $('#path-attribute-fill-opacity').val()
    _stroke = $('#path-attribute-stroke').val() or 'none'
    _stroke_width = $('#path-attribute-stroke-width').val() or 0
    _stroke_opacity = $('#path-attribute-stroke-opacity').val()
    @model.set x: _x, y: _y, rotate: _rotate, scale: _scale, fill: _fill, fill_opacity: _fill_opacity, stroke: _stroke, stroke_width: _stroke_width, stroke_opacity: _stroke_opacity

  update_form: =>
    $('#path-attribute-x').val(@model.get('x'))
    $('#path-attribute-y').val(@model.get('y'))

  update_shape: (e) =>
    _shape = $(e.currentTarget).val()
    @model.setPath(_shape)

  update_linecap: (e) =>
    _linecap = $(e.currentTarget).val()
    @model.setLinecap(_linecap)