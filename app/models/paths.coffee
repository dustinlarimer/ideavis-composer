Chaplin = require 'chaplin'
Collection = require 'models/base/collection'

Path = require 'models/path'

module.exports = class Paths extends Collection
  model: Path

  initialize: ->
    @on 'add', @path_created
    @on 'change', @path_updated
    @on 'remove', @path_removed

  path_created: =>
    console.log '[pub] path_created'
    @publishEvent 'path_created', this

  path_updated: (path) =>
    console.log '[pub] path_updated'
    @publishEvent 'path_updated'

  path_removed: (path) =>
    console.log '[pub] path_removed'
    @publishEvent 'path_removed', path