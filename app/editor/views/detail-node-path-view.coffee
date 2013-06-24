mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-node-path'

module.exports = class DetailNodePathView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    #console.log 'Initializing DetailNodePathView'
    #console.log @model
    @delegate 'change', 'input', @update_attributes
    @delegate 'click', '#path-attr-shape button', @update_shape

  #listen:
  #  'change model': 'update_form'

  update_attributes: =>
    console.log 'path:update_attributes'
    _x = $('#path-attr-x').val()
    _y = $('#path-attr-y').val()
    _rotate = $('#path-attr-rotate').val()
    _scale = $('#path-attr-scale').val()
    _fill = $('#path-attr-fill').val() or 'none'
    _stroke = $('#path-attr-stroke').val() or 'none'
    _stroke_width = $('#path-attr-stroke_width').val() or 0
    @model.set x: _x, y: _y, rotate: _rotate, scale: _scale, fill: _fill, stroke: _stroke, stroke_width: _stroke_width

  update_form: =>
    $('#path-attr-x').val(@model.get('x'))
    $('#path-attr-y').val(@model.get('y'))

  update_shape: (e) =>
    _shape = $(e.target).val()
    @model.setPath(_shape)