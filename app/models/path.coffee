Model = require 'models/base/model'

module.exports = class Path extends Model
  defaults:
    type: 'path',
    path: 'b',
    fill: '#FBFBFB',
    stroke: '#E5E5E5',
    stroke_width: 1,
    rotate: 0,
    scale: 0,
    x: 0,
    y: 0,
    visible: true

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @set('path', @defaultPath())

  defaultPath: d3.superformula().type("circle").size(3000)