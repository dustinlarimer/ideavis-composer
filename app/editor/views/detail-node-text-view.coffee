mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-node-text'

module.exports = class DetailNodeTextView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    console.log 'Initializing DetailNodeTextView'