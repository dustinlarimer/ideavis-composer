Chaplin = require 'chaplin'
mediator = require 'mediator'
routes = require 'routes'

User = require 'models/user'
Canvas = require 'models/canvas'
Nodes = require 'models/nodes'
Links = require 'models/links'

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
    mediator.current_user = new User payload?.current_user
    mediator.canvas = new Canvas _id: payload?.composition
    mediator.nodes = new Nodes
    mediator.links = new Links
    
    mediator.outer = undefined
    mediator.vis = undefined
    mediator.defs = undefined
    
    mediator.node = undefined
    mediator.selected_node = undefined

    mediator.link = undefined
    mediator.selected_link = undefined
    
    mediator.seal()