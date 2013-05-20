Chaplin = require 'chaplin'
Model = require 'models/base/model'
Canvas = require 'models/canvas'
Nodes = require 'models/nodes'

module.exports = class Composition extends Model
  _.extend @prototype, Chaplin.SyncMachine
  urlRoot: '/compositions/'

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @subscribeEvent 'canvas_attributes_updated', @saveCanvas

  fetch: (options = {}) ->
    @beginSync()
    success = options.success
    options.success = (model, response) =>
      success? model, response
      @canvas ?= new Canvas response.canvas
      @nodes ?= new Nodes
      @finishSync()
    super options

  saveCanvas: ->
    @set('canvas', @canvas.toJSON())
    @save()

  addNode: (data) ->
    new_node = @nodes.create(data)
    @publishEvent 'node_created', new_node

  updateCanvasAttributes: =>
    @publishEvent 'canvas_attributes_updated', this




