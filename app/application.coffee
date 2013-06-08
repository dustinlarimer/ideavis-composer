Chaplin = require 'chaplin'
mediator = require 'mediator'
routes = require 'routes'

CanvasController = undefined
EditorController = undefined
Canvas = require 'models/canvas'
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
    try EditorController = require 'editor/controllers/editor-controller'
    finally
      CanvasController = require 'controllers/canvas-controller'
    Object.freeze? this

  initMediator: ->
    mediator.canvas = new Canvas _id: payload?.composition
    mediator.current_user = new User payload?.current_user
    mediator.composition_id = payload?.composition
    
    mediator.outer = undefined
    mediator.vis = undefined
    mediator.nodes = undefined
    mediator.node = undefined
    
    mediator.seal()