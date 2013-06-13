Chaplin = require 'chaplin'
Model = require 'models/base/model'

module.exports = class Canvas extends Model
  _.extend @prototype, Chaplin.SyncMachine
  urlRoot: '/compositions/'

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @on 'change', @canvas_attributes_updated

  fetch: (options = {}) ->
    @beginSync()
    success = options.success
    options.success = (model, response) =>
      success? model, response
      @finishSync()
    super options

  canvas_attributes_updated: =>
    console.log '[pub] canvas_attributes_updated'
    @publishEvent 'canvas_attributes_updated', this