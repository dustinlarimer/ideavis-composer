mediator = require 'mediator'
CollectionView = require 'views/base/collection-view'

DetailNodeTextView = require 'editor/views/detail-node-text-view'

module.exports = class DetailNodeTextsView extends CollectionView
  tagName: 'div'
  itemView: DetailNodeTextView
  autoRender: true