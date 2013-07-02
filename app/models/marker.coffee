Model = require 'models/base/model'

module.exports = class Marker extends Model

  defaults: 
    fill: 'none'
    fill_opacity: 1
    offset_x: 0
    stroke: 'none'
    stroke_opacity: 1
    stroke_width: 0
    type: 'none'
    width: 20

  initialize: (data={}) ->
    super
    _.extend({}, data)