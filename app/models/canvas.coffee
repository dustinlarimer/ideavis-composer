Chaplin = require 'chaplin'
Model = require 'models/base/model'

Palette = require 'models/palette'

module.exports = class Canvas extends Model
  _.extend @prototype, Chaplin.SyncMachine
  urlRoot: '/compositions/'

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @on 'sync', @canvas_attributes_updated

  fetch: (options = {}) ->
    @beginSync()
    success = options.success
    options.success = (model, response) =>
      success? model, response
      @build_palette()
      @finishSync()
    super options

  canvas_attributes_updated: =>
    console.log '[pub] canvas_attributes_updated'
    @publishEvent 'canvas_attributes_updated', this

  build_palette: =>
    @colors = new Palette @get('palette')
    @listenTo @colors, 'add', @update_palette
    @listenTo @colors, 'change', @update_palette
    @listenTo @colors, 'remove', @update_palette

  update_palette: =>
    console.log 'update_palette'
    @set 'palette', @colors.toJSON() 
    @save()