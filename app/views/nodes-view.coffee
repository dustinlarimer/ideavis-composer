CollectionView = require 'views/base/collection-view'
NodeView = require 'views/node-view'

module.exports = class NodesView extends CollectionView
  autoRender: true
  itemView: NodeView

  initialize: ->
    console.log 'nodes-view loaded'
    #console.log @containerMethod
    @on 'add', @notifyNewItem

  notifyNewItem: ->
    console.log 'new node added'

  itemAdded: ->
    super
    console.log 'item added'