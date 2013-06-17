mediator = require 'mediator'
CollectionView = require 'views/base/collection-view'

DetailNodePathView = require 'editor/views/detail-node-path-view'

module.exports = class DetailNodePathsView extends CollectionView
  autoRender: true
  itemView: DetailNodePathView
  tagName: 'div'

  initialize: ->
    console.log 'Initializing this jam'