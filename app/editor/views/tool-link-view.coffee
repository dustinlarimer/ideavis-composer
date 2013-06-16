mediator = require 'mediator'
View = require 'views/base/view'

module.exports = class ToolLinkView extends View
  
  initialize: ->
    super
    console.log '[-- Link tool activated --]'
    @mode = 'link'
    
    $('#toolbar button.active').removeClass('active')
    $('#toolbar button#tool-link').addClass('active')
    mediator.outer.attr('cursor', 'crosshair')

    d3.selectAll('g.nodeGroup')
      .call(d3.behavior.drag()
        .on('dragstart', @node_select))

  remove: ->
    # Unbind delgated events ------
    # @$el.off 'event', '#selector'
    
    # Unbind D3 Events ------------
    d3.selectAll('g.nodeGroup')
      .call(d3.behavior.drag()
        .on('dragstart', null))
    
    # Unbind @el ------------------
    @setElement('')
    
    console.log '[xx Link tool out! xx]'
    super

  node_select: (d,i) ->
    if mediator.selected_node?
      _source = mediator.selected_node
      _target = d
      unless _target.model.id is _source.model.id
        mediator.links.create {source: _source.model.id, target: _target.model.id}

