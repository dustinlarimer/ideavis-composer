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
    
    #height: 40
    width: 80
    line_height: 24
    x: 0
    y: 0
    #rotate: 0

  initialize: (data) ->
    super
    _.extend({}, data)