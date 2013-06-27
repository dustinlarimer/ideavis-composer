Model = require 'models/base/model'

module.exports = class Link extends Model
  defaults:
    source: null
    target: null
    offsets: [[0,0],[0,0]]
    midpoints: []
    markers: []
    interpolation: 'linear'
    stroke: 'lightblue'
    stroke_dasharray: []
    stroke_linecap: 'round'
    stroke_linejoin: ''
    stroke_opacity: 1
    stroke_width: 5

  interpolation_types: ['linear', 'step-before', 'step-after', 'basis', 'cardinal']

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @interpolation = @interpolation_types[0] unless data.interpolation
    #console.log @interpolation

  save: ->
    console.log '[SAVE]'
    super
    @publishEvent 'link_updated', @

  destroy: ->
    super
    console.log '[LINK DESTROYED]'
    @publishEvent 'link_removed', @id