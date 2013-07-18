Chaplin = require 'chaplin'
mediator = require 'mediator'
Collection = require 'models/base/collection'
Line = require 'models/line'

module.exports = class Lines extends Collection
  _.extend @prototype, Chaplin.SyncMachine
  model: Line

  initialize: ->
    @url = '/compositions/' + mediator.canvas.id + '/lines/'
    @fetch()
    @on 'add', @line_created

  fetch: (options = {}) ->
    @beginSync()
    success = options.success
    options.success = (model, response) =>
      success? model, response
      @finishSync()
    super options

  line_created: (line) =>
    console.log '[pub] line_created'
    @publishEvent 'line_created', line