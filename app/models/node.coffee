Model = require 'models/base/model'
Path = require 'models/path'
Text = require 'models/text'

module.exports = class Path extends Model
  
  initialize: ->
    super

  defaults: {
    rotate: 0,
    scale: 0,
    x: 0, y: 0, # g.transform(x,y)
    nested: []
  }