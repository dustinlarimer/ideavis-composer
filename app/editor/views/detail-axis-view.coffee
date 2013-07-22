mediator = require 'mediator'
template = require 'editor/views/templates/detail-axis'
View = require 'views/base/view'

module.exports = class DetailAxisView extends View
  autoRender: true
  template: template

  initialize: (data={}) ->
    super

  render: ->
    super