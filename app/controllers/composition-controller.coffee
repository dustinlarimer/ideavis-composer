Controller = require 'controllers/base/controller'
CompositionView = require 'views/composition-view'

module.exports = class CompositionController extends Controller
  historyURL: 'composition'
  title: 'Composition'
  
  index: ->
    @view = new CompositionView()