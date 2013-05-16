Chaplin = require 'chaplin'
Model = require 'models/base/model'

module.exports = class User extends Model
  _.extend @prototype, Chaplin.SyncMachine
  urlRoot: '/users/'

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
      this.set(response)
      @finishSync()
    super options