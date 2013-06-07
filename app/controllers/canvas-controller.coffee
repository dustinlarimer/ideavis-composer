mediator = require 'mediator'
Controller = require 'controllers/base/controller'
CanvasView = require 'views/canvas-view'
Canvas = require 'models/canvas'

module.exports = class CanvasController extends Controller  
  index: ->
    @model = mediator.canvas
    @view = new CanvasView {@model}
    @model.fetch()