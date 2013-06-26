mediator = require 'mediator'
template = require 'editor/views/templates/detail-link'
View = require 'views/base/view'

module.exports = class DetailLinkView extends View
  autoRender: true
  template: template

  initialize: (data={}) ->
    super
    console.log 'Initialized DetailLinkView for Link #' + @model.id