Model = require 'models/base/model'

module.exports = class Link extends Model
  defaults:
    source: null
    target: null
    endpoints: [[0,0],[0,0]]
    midpoints: []
    markers: []
    interpolation: 'basis'
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
    #@interpolation = @interpolation_types[4] unless data.interpolation
    console.log @interpolation

  save: ->
    console.log '[SAVE]'
    super
    @publishEvent 'link_updated', @

  destroy: ->
    super
    console.log '[LINK DESTROYED]'
    @publishEvent 'link_removed', @id