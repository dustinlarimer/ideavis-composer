Chaplin = require 'chaplin'

module.exports = class RelationalModel extends Backbone.RelationalModel
  _(@prototype).extend Chaplin.EventBroker
  _(@prototype).extend Chaplin.SyncMachine

  idAttribute: '_id'
  url: ->
    url = super
    config.api.base_url + url

  attributes = ['getAttributes', 'serialize', 'disposed']
  for attr in attributes
    @::[attr] = Chaplin.Model::[attr]

  dispose: ->
    return if @disposed
    @trigger 'relational:unregister', this, @collection
    Chaplin.Model::dispose.call(this)