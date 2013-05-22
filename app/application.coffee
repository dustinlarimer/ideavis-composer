Chaplin = require 'chaplin'
mediator = require 'mediator'
routes = require 'routes'
CompositionController = require 'controllers/composition-controller'
Composition = require 'models/composition'
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
    new CompositionController(payload?.composition)
    #new CanvasController(payload?.composition_id)
    new EditorController if EditorController?

  initMediator: ->
    #mediator.current_user = new User payload?.current_user
    mediator.composition_id  = payload?.composition
    #mediator.nodes = new Nodes
    #mediator.links = new Links

    # Seal the mediator.
    mediator.seal()
