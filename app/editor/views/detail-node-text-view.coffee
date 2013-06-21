mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-node-text'

module.exports = class DetailNodeTextView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    console.log 'Initializing DetailNodeTextView'
    console.log @model
    @delegate 'change', 'input', @update_attributes
    @delegate 'change', 'select', @update_attributes

  listen:
    'change model': 'render'

  update_attributes: =>
    _x = $('#text-attr-x').val()
    _y = $('#text-attr-y').val()
    _rotate = $('#text-attr-rotate').val()
    _fontsize = $('#text-attr-fontsize').val()
    _fontweight = $('#text-attr-fontweight').val()
    @model.set x: _x, y: _y, rotate: _rotate, font_size: _fontsize, font_weight: _fontweight