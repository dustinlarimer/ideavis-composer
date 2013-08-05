Model = require 'models/base/model'

module.exports = class Marker extends Model

  defaults:
    type: 'none'
    fill: 'none'
    offset_x: 0
    width: 20

  initialize: (data={}) ->
    super
    _.extend({}, data)