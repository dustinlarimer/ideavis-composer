mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class AxisView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super
    @subscribeEvent 'deactivate_detail', @deactivate
    @subscribeEvent 'clear_active', @clear

  render: ->
    super
    console.log '[AxisView Rendered]'

  activate: ->
    d3.select(@el).classed 'active', true

  deactivate: ->
    @clear()
    @render()

  clear: ->
    d3.select(@el).classed 'active', false