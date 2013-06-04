Chaplin = require 'chaplin'
mediator = require 'mediator'
routes = require 'routes'

CanvasController = require 'controllers/canvas-controller'
Canvas = require 'models/canvas'
User = require 'models/user'
EditorController = undefined

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
    Object.freeze? this

  initControllers: ->
    new CanvasController payload?.composition
    new EditorController if EditorController?

  initMediator: ->
    #mediator.canvas = new Canvas {id: payload?.composition}
    #mediator.canvas.fetch()
    mediator.current_user = new User payload?.current_user
    mediator.composition_id = payload?.composition
    mediator.seal()