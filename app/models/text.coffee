Model = require 'models/base/model'

module.exports = class Text extends Model
  defaults:
    type: 'text'
    text: 'Label'
    
    font_size: 18
    fill: '#333'
    fill_opacity: 100
    #font_family: 'Helvetica Neue'
    
    stroke_width: 0
    stroke: null
    stroke_opacity: 100
    
    bold: false
    italic: false
    underline: false
    overline: false
    spacing: 0
    
    line_height: 24
    align: 'middle'
    width: 80
    
    x: 0
    y: 0

  initialize: (data) ->
    super
    _.extend({}, data)