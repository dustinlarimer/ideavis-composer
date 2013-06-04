Controller = require 'controllers/base/controller'
EditorView = require 'editor/views/editor-view'

module.exports = class EditorController extends Controller
  console.log 'EditorController is online'
  @index

  index: ->
    #@view = new EditorView