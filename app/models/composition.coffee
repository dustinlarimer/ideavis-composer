Chaplin = require 'chaplin'
Model = require 'models/base/model'
Nodes = require 'models/nodes'
Links = require 'models/links'

module.exports = class Composition extends Model
  _.extend @prototype, Chaplin.SyncMachine
  urlRoot: '/compositions/'

  constructor: (data) ->
    _.extend({}, data)
    super(data)

  initialize: ->
    super

  fetch: (options = {}) ->
    @beginSync()
    success = options.success
    options.success = (model, response) =>
      success? model, response
      this.get('canvas').nodes = new Nodes response.canvas.nodes
      this.get('canvas').links = new Links response.canvas.links
      @finishSync()
    super options