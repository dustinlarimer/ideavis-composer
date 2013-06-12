mediator = require 'mediator'
Chaplin = require 'chaplin'
Collection = require 'models/base/collection'
Node = require 'models/node'

module.exports = class Nodes extends Collection
  _.extend @prototype, Chaplin.SyncMachine
  model: Node

  initialize: ->
    @url = '/compositions/' + mediator.canvas.id + '/nodes/'
    @fetch()
    @on 'add', @node_created
    @on 'remove', @node_removed

  node_created: =>
    @publishEvent 'node_created', this

  node_removed: =>
    console.log 'node_removed: =>'
    #@publishEvent 'node_removed', this