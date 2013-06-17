mediator = require 'mediator'
template = require 'editor/views/templates/detail'
View = require 'views/base/view'

module.exports = class DetailView extends View
  autoRender: true
  el: '#detail'
  template: template
  
  initialize: ->
    super
    console.log '[-- Detail view activated --]'
    console.log @el
    @subscribeEvent 'activate_node_detail', @activate_node_detail

  activate_node_detail: (model) ->
    console.log 'Received model:'
    console.log model