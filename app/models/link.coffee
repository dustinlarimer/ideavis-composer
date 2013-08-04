Model = require 'models/base/model'

Marker = require 'models/marker'

module.exports = class Link extends Model
  defaults:
    source: null
    target: null
    endpoints: [[0,0],[0,0]]
    midpoints: []
    markers: [ (new Marker).toJSON(), (new Marker).toJSON() ]
    interpolation: 'basis'
    stroke: '#3498db'
    stroke_dasharray: []
    stroke_linecap: 'round'
    stroke_opacity: 50
    stroke_width: 5
    fill: 'none'
    
    label_text: 'Label'
    
    label_font_size: 12
    label_fill: '#999'
    label_fill_opacity: 100
    
    label_bold: false
    label_italic: false
    label_align: 'middle'
    label_spacing: 0

    label_offset_x: 25
    label_offset_y: 5

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @build_markers()

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

  build_markers: =>
    @marker_start = new Marker @get('markers')[0]
    @marker_end = new Marker @get('markers')[1]
    @listenTo @marker_start, 'change', @update_markers
    @listenTo @marker_end, 'change', @update_markers
