View = require 'views/base/view'
template = require 'views/templates/composition'
Node = require 'models/node'
Link = require 'models/link'
Path = require 'models/path'
Text = require 'models/text'

module.exports = class CompositionEditorView extends View
  #autoRender: true
  el: '#editor'
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

  node_drag = d3.behavior.drag()
    .on("dragstart", @dragstart)
    .on("drag", @dragmove)
    .on("dragend", @dragend)
  
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

  dragstart: (d, i) ->
    force.stop()
    mousedown_node = null if mousedown_node
  
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
      @draw()
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
         .nodes(@model.canvas.nodes.toJSON())
         #.links(@model.links.toJSON())
         .size([@model.get('canvas').width, @model.get('canvas').height])
         .start()
    
    @draw()

  applyCanvasAttributes: (canvas) ->
    console.log canvas.attributes.height
    console.log 'applyCanvasAttributes()'
    
    outer
      .attr('height', canvas.attributes.height)
      .attr('width', canvas.attributes.width)
    
    vis.select('rect')
      .attr('fill', canvas.attributes.fill)
      .attr('height', canvas.attributes.height)
      .attr('width', canvas.attributes.width)

  draw: ->
    console.log 'Drawing!'
    force
         .nodes(@model.canvas.nodes.toJSON())
         #.links(@model.links.toJSON())
         .start()
    nodes = force.nodes()
    #links = force.links()

    #link = vis.selectAll(".link").data(links)

    node = vis.selectAll(".node").data(nodes)
    node.enter().append('svg:circle')
        .attr("class", "node")
        .attr("cx", (d) -> d.x)
        .attr("cy", (d) -> d.y)
        .attr("r", (d) -> 25)
        .attr("fill", (d) -> 'grey')
        .attr("stroke", (d) -> '')
        .attr("stroke-width", (d) -> 0)
        .call(node_drag)
        .transition()
          .ease Math.sqrt
    node.exit().remove()

    d3.event.preventDefault() if d3.event
    force.start()

  force.on "tick", ->
    vis.selectAll("circle")
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)






