Model = require 'models/base/model'

module.exports = class Path extends Model
  defaults:
    type: 'path'
    path: 'M 0, 0  m -50, 0  a 50,50 0 1,0 100,0  a 50,50 0 1,0 -100,0'
    fill: '#FBFBFB'
    fill_opacity: 100
    stroke: '#E5E5E5'
    stroke_width: 1
    stroke_opacity: 100
    rotate: 0
    scale: 1
    x: 0
    y: 0
    visible: true

  initialize: (data={}) ->
    super
    _.extend({}, data)
    #@setPath('circle') unless @get('path')?

  setPath: (shape) ->
    @set('path', @build_path(shape))

  build_path: (shape) =>
    path = ''
    switch shape
      when 'circle'
        path = 'M 0, 0  m -50, 0  a 50,50 0 1,0 100,0  a 50,50 0 1,0 -100,0'
        break
      when 'square'
        path = 'M -50,-50 L 50,-50 L 50,50 L -50,50 Z'
        break
      when 'hexagon'
        path = 'M 0,-50 L 43,-25 L 43,25 L 0,50 L -43,25 L -43,-25 Z'
        break
    return path