CollectionView = require 'views/base/collection-view'
NodeView = require 'views/node-view'

module.exports = class NodesView extends CollectionView
  autoRender: true
  className: 'nodes'
  itemView: NodeView

  initialize: ->
    console.log 'nodes-view loaded'
    console.log @