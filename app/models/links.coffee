Chaplin = require 'chaplin'
mediator = require 'mediator'
Collection = require 'models/base/collection'
Link = require 'models/link'

module.exports = class Links extends Collection
  _.extend @prototype, Chaplin.SyncMachine
  model: Link

  initialize: ->
    #@url = '/compositions/' + mediator.canvas.id + '/links/'
    #@fetch()
    @on 'add', @link_created
    @on 'change', @link_updated
    @on 'remove', @link_removed

  link_created: =>
    console.log '[pub] link_created'
    @publishEvent 'link_created', this

  link_updated: (link) =>
    link.save()
    console.log '[pub] link_updated'
    @publishEvent 'link_updated'

  link_removed: =>
    console.log '[pub] link_removed'
    @publishEvent 'link_removed'