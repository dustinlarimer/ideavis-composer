mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class LinkView extends View
  autoRender: true
  
  initialize: (data={}) ->
    @paths = [{}]
    @subscribeEvent 'clear_active_links', @deactivate

  deactivate: ->
    d3.select(@el).classed 'active', false

  render: ->
    d3.select(@el)
      .selectAll('path')
      .data(@paths)
      .enter()
      .append('svg:path')
        .attr('fill', 'pink')
        .attr('opacity', 0.5)
        #.attr('d', (d) -> d.path)