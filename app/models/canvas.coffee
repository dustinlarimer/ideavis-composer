Chaplin = require 'chaplin'
Model = require 'models/base/model'

Nodes = require 'models/nodes'

module.exports = class Canvas extends Model
  _.extend @prototype, Chaplin.SyncMachine
  urlRoot: '/compositions/'

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @on 'change', @updateCanvasAttributes

  fetch: (options = {}) ->
    @beginSync()
    success = options.success
    options.success = (model, response) =>
      success? model, response
      @nodes ?= new Nodes
      @finishSync()
    super options

  updateCanvasAttributes: =>
    @publishEvent 'canvas_attributes_updated', this

  addNode: (data) ->
    new_node = @nodes.create(data)
    @publishEvent 'node_created', new_node

  updateCanvasAttributes: =>
    @publishEvent 'canvas_attributes_updated', this