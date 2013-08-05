Model = require 'models/base/model'

module.exports = class Path extends Model
  defaults:
    type: 'path'
    shape: 'circle'
    
    scale: 1
    height: 100
    width: 100
    fill: '#fbfbfb'
    fill_opacity: 100
    
    stroke_width: 5
    stroke: '#000'
    stroke_opacity: 20
    
    stroke_dasharray: []
    stroke_linecap: 'square'
    
    x: 0
    y: 0
    rotate: 0

  initialize: (data={}) ->
    super
    _.extend({}, data)