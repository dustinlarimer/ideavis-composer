Chaplin = require 'chaplin'
mediator = require 'mediator'
Collection = require 'models/base/collection'
Link = require 'models/link'

module.exports = class Links extends Collection
  _.extend @prototype, Chaplin.SyncMachine
  model: Link

  initialize: ->
    @url = '/compositions/' + mediator.canvas.id + '/links/'
    @fetch()
    @on 'add', @link_created
    #@on 'remove', @link_removed

  link_created: (link) =>
    console.log '[pub] link_created'
    @publishEvent 'link_created', link

  link_removed: (link) =>
    console.log '[pub] link_removed'
    @publishEvent 'link_removed', link.id