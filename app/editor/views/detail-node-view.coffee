mediator = require 'mediator'
template = require 'editor/views/templates/detail-node'
View = require 'views/base/view'

module.exports = class DetailNodeView extends View
  autoRender: true
  template: template

  initialize: (data={}) ->
    console.log 'Initialized DetailNodeView for Node #' + @model.id
    console.log @model

    @delegate 'change', '#node-attributes input', @update_attr

  listen:
    'change model': 'render'

  update_attr: ->
    @model.set x: $('#node-attr-x').val(), y: $('#node-attr-y').val()