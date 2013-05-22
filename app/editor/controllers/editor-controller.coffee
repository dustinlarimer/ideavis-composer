Controller = require 'controllers/base/controller'

module.exports = class EditorController extends Controller
  console.log 'Editor is online'
  @index

  index: ->
    @view = new EditorView