Chaplin = require 'chaplin'
mediator = require 'mediator'
Collection = require 'models/base/collection'
Node = require 'models/node'

module.exports = class Nodes extends Collection
  _.extend @prototype, Chaplin.SyncMachine
  model: Node

  initialize: ->
    @url = '/compositions/' + mediator.canvas.id + '/nodes/'
    @fetch()
    @on 'add', @node_created
    #@on 'remove', @node_removed

  node_created: (node) =>
    console.log '[pub] node_created'
    @publishEvent 'node_created', node

  node_removed: (node) =>
    console.log '[pub] node_removed'
    @publishEvent 'node_removed', node.id