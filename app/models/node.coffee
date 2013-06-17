Model = require 'models/base/model'

Paths = require 'models/paths'
Path = require 'models/path'

Texts = require 'models/texts'
Text = require 'models/text'

module.exports = class Node extends Model
  defaults:
    rotate: 0
    scale: 0
    x: 0 
    y: 0
    weight: 1
    nested: [ (new Path).toJSON(), (new Text).toJSON() ]

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @paths = new Paths _.where(@get('nested'), {type: 'path'})
    @texts = new Texts _.where(@get('nested'), {type: 'text'})