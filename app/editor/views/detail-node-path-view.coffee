mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-node-path'

module.exports = class DetailNodePathView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    console.log 'Initializing DetailNodePathView'
    console.log @model
    @delegate 'change', 'input', @update_attributes

  listen:
    'change model': 'render'

  update_attributes: =>
    _x = $('#path-attr-x').val()
    _y = $('#path-attr-y').val()
    _rotate = $('#path-attr-rotate').val()
    _scale = $('#path-attr-scale').val()
    @model.set x: _x, y: _y, rotate: _rotate, scale: _scale