Chaplin = require 'chaplin'
mediator = require 'mediator'
Controller = require 'controllers/base/controller'
CompositionView = require 'views/composition-view'
Composition = require 'models/composition'
User = require 'models/user'

module.exports = class CompositionController extends Controller
  historyURL: 'composition'
  title: 'Composition'
  
  index: ->
   user = mediator.user
   composition = mediator.composition
   @user = new User {_id: user}
   @model = new Composition {_id: composition._id, onwner: @user}
   @view = new CompositionView {@model}
   @model.fetch()