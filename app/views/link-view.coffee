mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class LinkView extends View
  autoRender: true
  
  initialize: (data={}) ->
    console.log 'Initializing LinkView [...]'
    @paths = [{}]
    
  render: ->
    console.log 'Rendering LinkView [...]'
    d3.select(@el)
      .selectAll('path')
      .data(@paths)
      .enter()
      .append('svg:path')
        .attr('fill', 'pink')
        .attr('opacity', 0.5)
        #.attr('d', (d) -> d.path)