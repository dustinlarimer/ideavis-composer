mediator = require 'mediator'
CollectionView = require 'views/base/collection-view'

DetailNodeTextView = require 'editor/views/detail-node-text-view'

module.exports = class DetailNodeTextsView extends CollectionView
  autoRender: true
  animationDuration: 0
  itemView: DetailNodeTextView
  tagName: 'div'