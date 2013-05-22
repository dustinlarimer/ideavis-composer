Chaplin = require 'chaplin'
View = require 'views/base/view'

module.exports = class EditorView extends View

  initialize: ->
    super
    Chaplin.mediator.subscribe 'hey', @catch_me

  catch_me: ->
    console.log 'I heard that!'
