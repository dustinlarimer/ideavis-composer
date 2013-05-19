Chaplin = require 'chaplin'
Model = require 'models/base/model'
Nodes = require 'models/nodes'
Links = require 'models/links'

module.exports = class Composition extends Model
  _.extend @prototype, Chaplin.SyncMachine
  urlRoot: '/compositions/'
  #defaults:
    #nodes: new Nodes
    #links: new Link

  initialize: (data={}) ->
    super
    _.extend({}, data)

  fetch: (options = {}) ->
    @beginSync()
    success = options.success
    options.success = (model, response) =>
      success? model, response
      
      @nodes ?= @get('canvas').nodes = new Nodes response.canvas.nodes
      @nodes.url = @urlRoot + @id + '/nodes/'
      @nodes.comp_id = @id
      @nodes.fetch()
      @nodes.on 'add', @addNode
      
      @links ?= @get('canvas').links = new Links response.canvas.links
      @links.url = @urlRoot + @id + '/links/'
      @links.comp_id = @id
      @links.on 'add', @addLink
      
      @finishSync()
    super options

  addNode: ->
    console.log 'Added a new node'

  addLink: ->
    console.log 'Added a new link'