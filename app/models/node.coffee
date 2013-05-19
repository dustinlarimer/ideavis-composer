Chaplin = require 'chaplin'
Model = require 'models/base/model'
Path = require 'models/path'
Text = require 'models/text'

module.exports = class Node extends Model  
  defaults:
    rotate: 0,
    scale: 0,
    x: 0, y: 0, # g.transform(x,y)
    nested: []

  initialize: (data={}) ->
    super
    _.extend({}, data)

  nest_default: ->
    new_default_object = new Path
    new_default_text = new Text
    this.attributes.nested.push(new_default_object)
    this.attributes.nested.push(new_default_text)