Model = require 'models/base/model'

module.exports = class Line extends Model
  defaults:
    endpoints: [[0,0],[0,0]]
    stroke: 'lightblue'
    stroke_dasharray: []
    stroke_linecap: 'round'
    stroke_opacity: 100
    stroke_width: 5
    
    #label_text: 'Label'
    
    #label_font_size: 12
    #label_fill: '#999'
    #label_fill_opacity: 100
    
    #label_offset_x: 75
    #label_offset_y: 5
    #label_spacing: 0

  initialize: (data={}) ->
    super
    _.extend({}, data)

  save: ->
    console.log '[SAVE]'
    super
    @publishEvent 'line_updated', @

  destroy: ->
    super
    console.log '[LINE DESTROYED]'
    @publishEvent 'line_removed', @id