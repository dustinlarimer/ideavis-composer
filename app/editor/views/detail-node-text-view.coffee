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
    _text = $('#text-attr-text').val()
    _x = $('#text-attr-x').val() or 0
    _y = $('#text-attr-y').val() or 0
    _rotate = $('#text-attr-rotate').val() or 0
    _fontsize = $('#text-attr-font_size').val() or 14
    _fontweight = $('#text-attr-font_weight').val() or 'normal'
    _fill = $('#text-attr-fill').val() or 'none'
    _stroke = $('#text-attr-stroke').val() or 'none'
    _stroke_width = $('#text-attr-stroke_width').val() or 0
    @model.set text: _text, x: _x, y: _y, rotate: _rotate, font_size: _fontsize, font_weight: _fontweight, fill: _fill, stroke: _stroke, stroke_width: _stroke_width