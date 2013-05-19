Chaplin = require 'chaplin'
Model = require 'models/base/model'
Path = require 'models/path'
Text = require 'models/text'

module.exports = class Node extends Model  
  defaults:
    rotate: 0,
    scale: 0,
    x: 0, y: 0, # g.transform(x,y)
    nested: [ new Path, new Text ]

  initialize: (data={}) ->
    super
    _.extend({}, data)