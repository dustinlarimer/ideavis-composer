View = require 'views/base/view'

module.exports = class NodeView extends View
  initialize: ->
    console.log 'node-view ready'

  render: ->
    #console.log this