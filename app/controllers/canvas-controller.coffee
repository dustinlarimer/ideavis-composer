mediator = require 'mediator'
Controller = require 'controllers/base/controller'

Canvas = require 'models/canvas'
CanvasView = require 'views/canvas-view'
EditorView = undefined

module.exports = class CanvasController extends Controller
  index: ->
    @model = mediator.canvas
    try 
      EditorView = require 'editor/views/editor-view'
      @view = new EditorView {@model}
    catch error
      @view = new CanvasView {@model}
    @model.fetch()