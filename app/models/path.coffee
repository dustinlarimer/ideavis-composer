Model = require 'models/base/model'

module.exports = class Path extends Model
  
  initialize: ->
    super

  defaults=
    type: 'path',
    path: '',
    fill: '#FBFBFB',
    stroke: '#E5E5E5',
    stroke_width: 1,
    rotate: 0,
    scale: 0,
    x: 0,
    y: 0,
    visible: true