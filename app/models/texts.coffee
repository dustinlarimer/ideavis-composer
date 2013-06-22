Chaplin = require 'chaplin'
Collection = require 'models/base/collection'

Text = require 'models/text'

module.exports = class Texts extends Collection
  model: Text

  initialize: (data={}) ->
    @on 'add', @text_created
    @on 'change', @text_updated
    @on 'remove', @text_removed

  text_created: =>
    console.log '[pub] text_created'
    @publishEvent 'text_created', this

  text_updated: (text) =>
    console.log '[pub] text_updated'
    @publishEvent 'text_updated'

  text_removed: (text) =>
    console.log '[pub] text_removed'
    @publishEvent 'text_removed', text