mediator = require 'mediator'
Controller = require 'controllers/base/controller'
CanvasView = require 'views/canvas-view'
Canvas = require 'models/canvas'

module.exports = class CanvasController extends Controller  
  index: ->
    @model = new Canvas _id: payload?.composition
    @view = new CanvasView {@model}
    @model.fetch()