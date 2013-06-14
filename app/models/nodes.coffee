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
    @on 'change', @node_updated
    @on 'remove', @node_removed

  node_created: =>
    console.log '[pub] node_created'
    @publishEvent 'node_created', this

  node_updated: (node) =>
    node.save()
    console.log '[pub] node_updated'
    @publishEvent 'node_updated'

  node_removed: (node) =>
    console.log '[pub] node_removed'
    @publishEvent 'node_removed', node