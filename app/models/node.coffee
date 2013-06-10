mediator = require 'mediator'
Chaplin = require 'chaplin'
Model = require 'models/base/model'
Path = require 'models/path'
Text = require 'models/text'

module.exports = class Node extends Model
  defaults:
    rotate: 0,
    scale: 0,
    x: 0, 
    y: 0,
    nested: [ (new Path).toJSON(), (new Text).toJSON() ]

  initialize: (data={}) ->
    super
    _.extend({}, data)
    
    #@paths = _.where(@get('nested'), {type: 'path'})
    #@texts = _.where(@get('nested'), {type: 'text'})
    #console.log @paths
    
    @on 'change', @updateNodeAttributes

  updateNodeAttributes: =>
    @save()
    console.log 'updateNodeAttributes'
    @publishEvent 'node_attributes_updated', this