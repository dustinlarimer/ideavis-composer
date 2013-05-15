Model = require 'models/base/model'
Path = require 'models/path'
Text = require 'models/text'

module.exports = class Path extends Model
  
  initialize: ->
    super

  defaults: {
    source: null,
    target: null,
    nested: []
  }