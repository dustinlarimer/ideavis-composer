mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-node-text'

module.exports = class DetailNodeTextView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    #console.log 'Initializing DetailNodeTextView'
    #console.log @model
    @delegate 'change', 'input', @update_attributes
    @delegate 'change', 'select', @update_attributes

  #listen:
  #  'change model': 'render'

  update_attributes: =>
    _text = $('#text-attribute-text').val()
    _x = $('#text-attribute-x').val() or 0
    _y = $('#text-attribute-y').val() or 0
    _rotate = $('#text-attribute-rotate').val() or 0
    _font_size = $('#text-attribute-font-size').val() or 14
    _font_weight = $('#text-attribute-font-weight').val() or 'normal'
    _fill = $('#text-attribute-fill').val() or 'none'
    _fill_opacity = $('#text-attribute-fill-opacity').val()
    _stroke = $('#text-attribute-stroke').val() or 'none'
    _stroke_width = $('#text-attribute-stroke-width').val() or 0
    _stroke_opacity = $('#text-attribute-stroke-opacity').val()
    @model.set text: _text, x: _x, y: _y, rotate: _rotate, font_size: _font_size, font_weight: _font_weight, fill: _fill, fill_opacity: _fill_opacity, stroke: _stroke, stroke_width: _stroke_width, stroke_opacity: _stroke_opacity