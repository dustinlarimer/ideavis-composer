Model = require 'models/base/model'

module.exports = class Marker extends Model

  defaults: 
    fill: 'none'
    fill_opacity: 1
    height: 0
    offset_x: 0
    path: ''
    stroke: 'none'
    stroke_opacity: 1
    type: 'none'
    viewBox: ''
    width: 0

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @form(data.type or 'none') if data.type? or @get('path') is ''

  #setPath: (shape) =>
  #  @set type: shape, path: @form(shape)

  form: (type) =>
    _type = type
    _path = ''
    _viewBox = ''
    switch type
      when 'none'
        _path = 'M 0,0'
        _viewBox = '0 0 0 0'
        break
      when 'circle'
        _path = 'M 0, 0  m -5, 0  a 5,5 0 1,0 10,0  a 5,5 0 1,0 -10,0'
        _viewbox = ''
        break
      when 'square'
        _path = 'M -50,-50 L 50,-50 L 50,50 L -50,50 Z'
        _viewbox = ''
        break
      when 'stem'
        _path = ''
        _viewbox = ''
        break
      when 'plus'
        _path = ''
        _viewbox = ''
        break
      when 'acute'
        _path = ''
        _viewbox = ''
        break
      when 'right'
        _path = ''
        _viewbox = ''
        break
      when 'sharp'
        _path = ''
        _viewbox = ''
        break
      when 'reverse'
        _path = 'M 0,0 m 0,-10 L -20,0 L 0,10 z'
        _viewbox = ''
        break
    @set type: _type, path: _path, viewBox: _viewBox
    # height: _height, width: _width, 







