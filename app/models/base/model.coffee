config = require 'config'
Chaplin = require 'chaplin'

module.exports = class Model extends Chaplin.Model
  idAttribute: '_id'
  url: ->
    url = super
    config.api.base_url + url

  # Mixin a synchronization state machine
  # _(@prototype).extend Chaplin.SyncMachine
