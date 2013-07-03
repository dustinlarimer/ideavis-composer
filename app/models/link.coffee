Model = require 'models/base/model'

Marker = require 'models/marker'

module.exports = class Link extends Model
  defaults:
    source: null
    target: null
    endpoints: [[0,0],[0,0]]
    midpoints: []
    markers: [ (new Marker type:'circle').toJSON(), (new Marker type:'circle').toJSON() ]
    interpolation: 'basis'
    stroke: 'lightblue'
    stroke_dasharray: []
    stroke_linecap: 'round'
    stroke_opacity: 1
    stroke_width: 5
    label_fill: '#999'
    label_font_size: 12
    label_offset_x: 75
    label_offset_y: 5
    label_text: 'Label'

  interpolation_types: ['linear', 'step-before', 'step-after', 'basis', 'cardinal']

  initialize: (data={}) ->
    super
    _.extend({}, data)
    #@interpolation = @interpolation_types[4] unless data.interpolation
    @marker_start = new Marker @get('markers')[0]
    @marker_end = new Marker @get('markers')[1]
    @listenTo @marker_start, 'change', @update_markers
    @listenTo @marker_end, 'change', @update_markers

  save: ->
    console.log '[SAVE]'
    super
    @publishEvent 'link_updated', @

  destroy: ->
    super
    console.log '[LINK DESTROYED]'
    @publishEvent 'link_removed', @id

  update_markers: =>
    console.log 'Marker changed'
    _markers = [ @marker_start.toJSON(), @marker_end.toJSON() ]
    @save markers: _markers

