View = require 'views/base/view'
template = require 'views/templates/composition'
Node = require 'models/node'
Link = require 'models/link'
Path = require 'models/path'
Text = require 'models/text'
NodesView = require 'views/nodes-view'
NodeView = require 'views/node-view'

module.exports = class CompositionEditorView extends View
  #autoRender: true
  el: '#canvas'
  template: template
  regions:
    '#controls': 'controls'
    '#stage': 'stage'

  #listen:
    #'change model': -> console.log 'Model has changed'

  initialize: ->
    super
    
    @delegate 'mousemove', 'svg > g', @mousemove
    @delegate 'mousedown', 'svg > g', @mousedown
    @delegate 'mouseup', 'svg > g', @mouseup
    d3.select(window).on("keydown", @keydown)
    
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()
    @subscribeEvent 'canvas_attributes_updated', @applyCanvasAttributes
    @subscribeEvent 'node_created', @draw
    
    @model.synced =>
      unless @rendered
        @render()
        @rendered = yes

  shortcuts:
    'shift+t' : 'shifty'

  force = d3.layout.force()
  outer = undefined
  vis   = undefined
  nodes = undefined
  links = undefined
  node  = undefined
  link  = undefined

  selected_node = null
  selected_link = null
  mousedown_link = null
  mousedown_node = null
  mouseup_node = null
  keydown_code = null
  
  shifty: ->
    console.log 'Keyboard shortcuts enabled'

  keydown: ->
    #console.log 'Keycode ' + d3.event.keyCode + ' pressed.'
    switch d3.event.keyCode
      when 8, 46
        nodes.splice nodes.indexOf(selected_node), 1  if selected_node
        selected_node = null
        @draw()
        break

  drag_group_start: (d, i) ->
    console.log 'starting drag'
    force.stop()

  drag_group_move: (d, i) ->
    d3.select(@).attr('transform', 'translate('+ d3.event.x + ',' + d3.event.y + ')')
    force.tick()
  
  drag_group_end: (d, i) ->
    nodes[i].set({x: d3.event.sourceEvent.x, y: d3.event.sourceEvent.y})
    console.log nodes.length
    force.tick()
    force.resume()

  dragmove: (d, i) ->
    d.px += d3.event.dx
    d.py += d3.event.dy
    d.x += d3.event.dx
    d.y += d3.event.dy
    force.tick()
  
  dragend: (d, i) ->
    force.tick()
    force.resume()

  mousedown: ->
    #console.log ':mousedown'
    unless mousedown_node?
      selected_node = null
      #@draw()

  mousemove: ->
    #console.log ':mousemove'
  
  mouseup: (e) ->
    #console.log ':mouseup'
    unless mouseup_node?
      @model.addNode({x: e.offsetX, y: e.offsetY})
      @resetMouseVars

  resetMouseVars: ->
    mousedown_node = null
    mouseup_node = null
    mousedown_link = null

  rescale: ->
    trans = d3.event.translate
    scale = d3.event.scale
    vis.attr "transform", "translate(" + trans + ")" + " scale(" + scale + ")"

  render: ->
    super
    outer = d3.select("#stage")
      .append('svg:svg')
      .attr('pointer-events', 'all')
    vis = outer.append('svg:g')
    vis.append("svg:rect")
       .attr('x', 10)
       .attr('y', 50)
    @applyCanvasAttributes(@model.canvas)
    force
         .charge(0)
         .gravity(0)
         .nodes(@model.nodes.models)
         .size([@model.get('canvas').width, @model.get('canvas').height])
         .start()
    nodes = force.nodes()
    node = vis.selectAll(".node")
    @draw()

  applyCanvasAttributes: (canvas) ->
    console.log 'applyCanvasAttributes()'
    outer
      .attr('height', canvas.attributes.height)
      .attr('width', canvas.attributes.width)
    vis.select('rect')
      .attr('fill', canvas.attributes.fill)
      .attr('height', canvas.attributes.height)
      .attr('width', canvas.attributes.width)
    force
      .size([canvas.attributes.width, canvas.attributes.height])
      .start()

  draw: ->
    console.log 'Drawing!'
    drag_group = d3.behavior.drag()
      .on('dragstart', @drag_group_start)
      .on('drag', @drag_group_move)
      .on('dragend', @drag_group_end)
    node = node.data(nodes)
    node.enter()
        .append('svg:g')
        .attr('class', 'nodeGroup')
        .attr('transform', (d) -> 'translate('+ d.attributes.x + ',' + d.attributes.y + ')')
        .call(drag_group)
        .each((d,i)-> new NodeView({model: d, el: @}))
        .transition()
          .ease Math.sqrt
    node.exit().remove()
    
    d3.event.preventDefault() if d3.event
    force.start()

  force.on "tick", ->
    vis.selectAll("g.nodeGroup")
      #.attr('transform', (d) -> 'translate('+ d.attributes.x + ',' + d.attributes.y + ')')





