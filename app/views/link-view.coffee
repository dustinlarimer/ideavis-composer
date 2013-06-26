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
      .attr('stroke-width', (d)-> d.model.get('stroke_width'))
      .attr('fill', 'none')
      .attr('marker-end', (d)-> return 'url(#' + 'link_' + d.id + '_marker_end)')


  # ----------------------------------
  # BUILD Markers
  # ----------------------------------
  build_markers: =>
    console.log @model.get('marker_end')
    marker_end = d3.select('defs')
      .append('svg:marker')
        .attr('id', 'link_' + @model.id + '_marker_end')

    marker_end
        .attr('markerUnits', 'strokeWidth')
        .attr('orient', 'auto')
        .attr('refX', 0)
        .attr('refY', 0)

    #marker_end
    #    .attr('viewBox', '0 -5 10 10')
    #    .attr('markerHeight', 3)
    #    .attr('markerWidth', 4)
    #    .append('svg:path')
    #      .attr('d', 'M 0,0 m 0,-5 L 10,0 L 0,5 z')
    #      .attr('fill', '#333333')

    #'reverse'
    sw = @model.get('stroke_width')
    rev_w = 2 * sw
    rev_min_x = -2 * sw
    rev_min_y = -1 * sw/2
    rev_max_y = sw/2
    rev_v = '' + rev_min_x + ' ' + rev_min_y + ' ' + rev_w + ' ' + sw
    rev_d = 'M 0,0 m 0,' + rev_min_y + ' L ' + rev_min_x + ',0 L 0,' + rev_max_y + ' z'
    
    rev_width_px = 30 # 'user says 30px'
    rev_scale = rev_width_px / sw
    
    marker_end
        .attr('viewBox', rev_v)
        .attr('markerHeight', 1*rev_scale)
        .attr('markerWidth', 2*rev_scale)
        .append('svg:path')
          .attr('d', rev_d)
          #.attr('d', 'M 0,0 m 0,-10 L -20,0 L 0,10 z')
          .attr('fill', '#3498DB')
          .attr('opacity', .5)

