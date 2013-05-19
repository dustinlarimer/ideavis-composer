mediator = require 'mediator'
Collection = require 'models/base/collection'
Node = require 'models/node'

module.exports = class Nodes extends Collection
  model: Node

  initialize: ->
    super
    this.urlRoot = '/composition/' + mediator.composition + '/nodes/'