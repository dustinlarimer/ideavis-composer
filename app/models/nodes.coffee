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
    @on 'add', @updateNodes
    @on 'remove', @removeNode

  updateNodes: =>
    @publishEvent 'node_created', this

  removeNode: =>
    console.log 'removeNode'
    #@publishEvent 'node_removed', this