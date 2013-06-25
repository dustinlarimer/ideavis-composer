mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class LinkView extends View
  autoRender: true
  
  initialize: (data={}) ->
    super
    @paths = [{}]
    @subscribeEvent 'clear_active_links', @deactivate
    @source = data.source
    @target = data.target
    
    @baseline = d3.select(@el)
      .append('svg:path')
      .attr('class', 'baseline')
    
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
      .attr('stroke-width', 5)
      .attr('fill', 'none')
      .attr('opacity', 0.5)
