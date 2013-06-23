Model = require 'models/base/model'

module.exports = class Link extends Model
  defaults:
    source: null
    target: null

  initialize: (data={}) ->
    super
    _.extend({}, data)

  save: ->
    console.log '[SAVE]'
    super
    @publishEvent 'link_updated', @

  destroy: ->
    super
    console.log '[LINK DESTROYED]'
    @publishEvent 'link_removed', @id