Model = require 'models/base/model'
Path = require 'models/path'
Text = require 'models/text'

module.exports = class Path extends Model
  defaults=
    rotate: 0,
    scale: 0,
    x: 0, y: 0, # g.transform(x,y)
    nested: []

  constructor: (data) ->
    _.extend({}, data)
    super(data)  

  initialize: ->
    super