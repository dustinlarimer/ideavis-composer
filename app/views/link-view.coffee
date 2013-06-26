mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class LinkView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super
    @subscribeEvent 'clear_active', @clear
    @source = data.source
    @target = data.target
    
    @baseline = d3.select(@el)
      .append('svg:path')
      .attr('class', 'baseline')

  activate: ->
    console.log 'Link activated'
    d3.select(@el)
      .classed('active', true)

  deactivate: ->
    d3.select(@el).classed 'active', false

  render: ->
    super
    @build_baseline()

  # ----------------------------------
  # BUILD Baseline
  # ----------------------------------
  build_baseline: =>
    @baseline
      .attr('stroke', 'lightblue')
      .attr('stroke-dasharray', 'none')
      .attr('stroke-linecap', 'round')
      .attr('stroke-linejoin', 'round')
      .attr('stroke-opacity', .75)
      .attr('stroke-width', 5)
      .attr('fill', 'none')

  clear: ->
    d3.select(@el).classed 'active', false