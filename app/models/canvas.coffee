Model = require 'models/base/model'
Nodes = require 'models/nodes'

module.exports = class Canvas extends Model
  defaults:
    nodes: new Nodes

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @on 'change', @updateCanvasAttributes

  updateCanvasAttributes: =>
    @publishEvent 'canvas_attributes_updated', this