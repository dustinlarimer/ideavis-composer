Model = require 'models/base/model'

module.exports = class Text extends Model
  defaults:
    type: 'text',
    text: 'Text',
    fill: '#000000',
    stroke: null,
    stroke_width: 0,
    rotate: 0,
    font_family: 'Helvetica Neue',
    font_size:  14,
    font_weight: 'normal',
    x: 0,
    y: 0,
    visible: true

  initialize: (data) ->
    super
    _.extend({}, data)