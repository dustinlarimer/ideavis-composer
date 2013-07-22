Model = require 'models/base/model'

module.exports = class Axis extends Model
  defaults:
    endpoints: [[0,0],[0,0]]
    rotate: 0
    x: 0
    y: 0
    
    stroke: '#000'
    stroke_dasharray: []
    stroke_linecap: 'square'
    stroke_opacity: 100
    stroke_width: 1
    
    label_text: 'Axis label'
    
    label_font_size: 12
    label_fill: '#999'
    label_fill_opacity: 100
    
    label_bold: false
    label_italic: false
    label_align: 'start'
    label_spacing: 0

    label_offset_x: 0
    label_offset_y: 5

  initialize: (data={}) ->
    super
    _.extend({}, data)

  save: ->
    console.log '[SAVE]'
    super
    @publishEvent 'axis_updated', @

  destroy: ->
    super
    console.log '[AXIS DESTROYED]'
    @publishEvent 'axis_removed', @id