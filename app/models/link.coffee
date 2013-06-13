Model = require 'models/base/model'

module.exports = class Link extends Model
  defaults:
    source: null
    target: null

  initialize: (data={}) ->
    super
    _.extend({}, data)