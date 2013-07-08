Model = require 'models/base/model'

module.exports = class Marker extends Model

  defaults:
    type: 'none'
    offset_x: 0
    
    width: 20
    fill: 'none'
    fill_opacity: 1
    
    stroke_width: 0
    stroke: 'none'
    stroke_opacity: 1



  initialize: (data={}) ->
    super
    _.extend({}, data)