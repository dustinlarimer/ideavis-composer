View = require 'views/base/view'
template = require 'views/templates/composition'

module.exports = class CompositionView extends View
  autoRender: true
  el: '#editor'
  regions:
    '#controls': 'controls'
    '#stage': 'stage'
  template: template

  initialize: ->
    super
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

  shortcuts:
    'shift+t' : 'shifty'

  shifty: =>
    console.log 'Shifty! shift + t shortcut pressed!'