Model = require 'models/base/model'

module.exports = class Path extends Model
  defaults:
    type: 'path'
    path: 'M 0, 0  m -50, 0  a 50,50 0 1,0 100,0  a 50,50 0 1,0 -100,0'
    shape: 'circle'
    
    scale: 1
    fill: '#FBFBFB'
    fill_opacity: 100
    
    stroke_width: 1
    stroke: '#E5E5E5'
    stroke_opacity: 100
    
    stroke_dasharray: []
    stroke_linecap: 'square'
    
    x: 0
    y: 0
    rotate: 0

  initialize: (data={}) ->
    super
    _.extend({}, data)
    #@setPath('circle') unless @get('path')?

  setPath: (shape) ->
    @set path: @build_path(shape), shape: shape

  build_path: (shape) =>
    #console.log d3.svg.symbol().type('cross')()
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
      when 'triangle'
        path = 'M 0,-50 L 50,40 L -50,40 Z'
        break
      when 'plus'
        path = 'M -50,-20 L -20,-20 L -20,-50 L 20,-50 L 20,-20 L 50,-20 L 50,20 L 20,20 L 20,50 L -20,50 L -20,20 L -50,20 Z'
        break
      when 'none'
        path = 'M 0,0'
        break
    return path