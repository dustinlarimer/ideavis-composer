Model = require 'models/base/model'

Paths = require 'models/paths'
Path = require 'models/path'

Texts = require 'models/texts'
Text = require 'models/text'

module.exports = class Node extends Model
  defaults:
    rotate: 0
    scale: 1
    x: 0 
    y: 0
    weight: 1
    nested: [ (new Path).toJSON(), (new Text).toJSON() ]

  initialize: (data={}) ->
    super
    _.extend({}, data)
    @paths = new Paths _.where(@get('nested'), {type: 'path'})
    @texts = new Texts _.where(@get('nested'), {type: 'text'})
    
    @listenTo @paths, 'change', @update_nested
    @listenTo @texts, 'change', @update_nested

  save: ->
    console.log '[SAVE]'
    super
    @publishEvent 'node_updated', @

  update_nested: ->
    _nested = []
    _.each(@paths.toJSON(), (p)-> _nested.push p)
    _.each(@texts.toJSON(), (t)-> _nested.push t)
    @save nested: _nested