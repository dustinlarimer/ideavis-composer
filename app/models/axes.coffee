Chaplin = require 'chaplin'
mediator = require 'mediator'
Collection = require 'models/base/collection'
Axis = require 'models/axis'

module.exports = class Axes extends Collection
  _.extend @prototype, Chaplin.SyncMachine
  model: Axis

  initialize: ->
    @url = '/compositions/' + mediator.canvas.id + '/axes/'
    @fetch()
    @on 'add', @axis_created

  fetch: (options = {}) ->
    @beginSync()
    success = options.success
    options.success = (model, response) =>
      success? model, response
      @finishSync()
    super options

  axis_created: (axis) =>
    console.log '[pub] axis_created'
    @publishEvent 'axis_created', axis