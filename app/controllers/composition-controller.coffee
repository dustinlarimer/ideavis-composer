Controller = require 'controllers/base/controller'
CompositionView = require 'views/composition-view'
Composition = require 'models/composition'

module.exports = class CompositionController extends Controller
  historyURL: 'composition'
  title: 'Composition'
  
  index: ->
    @model = new Composition {_id: payload?.composition}
    @node_collection = @model.nodes
    @view = new CompositionView {@model}
    @model.fetch()