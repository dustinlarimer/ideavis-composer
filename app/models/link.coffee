Model = require 'models/base/model'
Path = require 'models/path'
Text = require 'models/text'

module.exports = class Path extends Model
  defaults:
    source: null,
    target: null,
    nested: []

  constructor: (data) ->
    _.extend({}, data)
    super(data)  

  initialize: ->
    super