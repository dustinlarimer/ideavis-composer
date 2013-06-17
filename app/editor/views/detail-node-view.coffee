mediator = require 'mediator'
template = require 'editor/views/templates/detail-node'
View = require 'views/base/view'

module.exports = class DetailNodeView extends View
  autoRender: true
  template: template

  initialize: (data={}) ->
    console.log 'Initialized DetailNodeView for Node #' + @model.id
    console.log @model

  listen:
    'change model': 'render'