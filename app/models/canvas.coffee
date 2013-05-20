Model = require 'models/base/model'

module.exports = class Canvas extends Model
  initialize: (data={}) ->
    super
    _.extend({}, data)
    @on 'change', @updateCanvasAttributes

  updateCanvasAttributes: =>
    @publishEvent 'canvas_attributes_updated', this