Chaplin = require 'chaplin'
mediator = require 'mediator'
Collection = require 'models/base/collection'
Link = require 'models/link'

module.exports = class Links extends Collection
  _.extend @prototype, Chaplin.SyncMachine
  model: Link

  initialize: ->
    @url = '/compositions/' + mediator.canvas.id + '/links/'
    @fetch()
    @on 'add', @link_created

  fetch: (options = {}) ->
    @beginSync()
    success = options.success
    options.success = (model, response) =>
      success? model, response
      @finishSync()
    super options

  link_created: (link) =>
    console.log '[pub] link_created'
    @publishEvent 'link_created', link