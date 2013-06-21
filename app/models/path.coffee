Model = require 'models/base/model'

module.exports = class Path extends Model
  defaults:
    type: 'path',
    path: '',
    fill: '#FBFBFB',
    stroke: '#E5E5E5',
    stroke_width: 1,
    rotate: 0,
    scale: 1,
    x: 0,
    y: 0,
    visible: true

  initialize: (data={}) ->
    super
    _.extend({}, data)
    #@setPath('circle')

  setPath: (shape) ->
    @set('path', @buildPath(shape))

  buildPath: (shape) =>
    size = 0
    segments = 0
    switch shape
      when 'circle'
        size = 4800
        segments = 360
        break
      when 'square'
        size = 9600
        segments = 16
        break
      when 'hexagon'
        size = 6400
        segments = 6
    d = d3.superformula().type(shape).size(size).segments(segments)
    return d()

  #defaultPath: return d3.superformula().type("hexagon").size(4800).segments(6)