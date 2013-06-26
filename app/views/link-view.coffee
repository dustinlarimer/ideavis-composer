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

  clear: ->
    d3.select(@el).classed 'active', false


  # ----------------------------------
  # BUILD Baseline
  # ----------------------------------
  build_baseline: =>
    @build_markers()
    @baseline
      .attr('stroke', 'lightblue')
      .attr('stroke-dasharray', 'none')
      .attr('stroke-linecap', 'round')
      .attr('stroke-linejoin', 'round')
      .attr('stroke-opacity', .75)
      .attr('stroke-width', 5)
      .attr('fill', 'none')
      .attr('marker-end', (d)-> return 'url(#' + 'link_' + d.id + '_marker_end)')


  # ----------------------------------
  # BUILD Markers
  # ----------------------------------
  build_markers: =>
    console.log @model.get('marker_end')
    d3.select('defs')
      .append('svg:marker')
        .attr('id', 'link_' + @model.id + '_marker_end')
        #.attr('viewBox', '0 0 10 10')
        .attr('viewBox', '-30 -10 30 20')
        .attr('refX', 0)
        #.attr('refY', 5)
        .attr('refY', 0)
        .attr('markerUnits', 'strokeWidth')
        .attr('markerHeight', 30)
        .attr('markerWidth', 10)
        .attr('orient', 'auto')
        .append('svg:path')
          .attr('d', 'M 0,0 m 0,-10 L -30,0 L 0,10 z')
          .attr('fill', '#3498DB')
          #.attr('d', 'M 0,0 L 10,5 L 0,10 z')









