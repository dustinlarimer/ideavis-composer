Chaplin = require 'chaplin'
mediator = require 'mediator'
routes = require 'routes'

Canvas = require 'models/canvas'
Nodes = require 'models/nodes'

User = require 'models/user'

module.exports = class Application extends Chaplin.Application
  initialize: ->
    super
    @initRouter routes, root: window.location.pathname
    @initDispatcher controllerSuffix: '-controller'
    @initLayout()
    @initComposer()
    @initMediator()
    @startRouting()
    Object.freeze? this
  
  initMediator: ->
    mediator.canvas = new Canvas _id: payload?.composition
    mediator.current_user = new User payload?.current_user
    
    mediator.outer = undefined
    mediator.vis = undefined
    mediator.nodes = new Nodes
    mediator.node = undefined
    mediator.selected_node = undefined
    
    mediator.seal()