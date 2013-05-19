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

  listen:
    'change model': -> console.log 'Model has changed'

  initialize: ->
    super
    
    #@delegate 'keydown', 'window', @keydown
    @delegate 'mousemove', 'svg > g', @mousemove
    @delegate 'mousedown', 'svg > g', @mousedown
    @delegate 'mouseup', 'svg > g', @mouseup
    d3.select(window).on("keydown", @keydown)
    
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()
    
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
    console.log 'Keycode ' + d3.event.keyCode + ' pressed.'
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
      new_node = new Node {x: e.offsetX, y: e.offsetY}
      new_node.nest_default()
      #new_node.save()
      @model.get('canvas').nodes.add(new_node)
      #@model.get('canvas').nodes.save()
      #console.log @model
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
    #@model.get('canvas').nodes = []
    #@model.save()
    outer = d3.select("#stage")
      .append('svg:svg')
      .attr('width', @model.get('canvas').width)
      .attr('height', @model.get('canvas').height)
      .attr('pointer-events', 'all')
    
    vis = outer.append('svg:g')
    vis.append("svg:rect")
        .attr("fill", @model.get('canvas').fill)
        .attr("height", @model.get('canvas').height)
        .attr("width", @model.get('canvas').width)
        .attr('x', 10)
        .attr('y', 50)
    
    force
         .charge(0)
         .gravity(0)
         .nodes(@model.get('canvas').nodes.toJSON())
         .links(@model.get('canvas').links.toJSON())
         .size([@model.get('canvas').width, @model.get('canvas').height])
         .start()
    
    @draw()
    
    adjust = ->
      setInterval ( -> 
        stage.height = $('#stage').height()
        stage.width = $('#stage').width()
        #$("#stage svg")
        #  .attr('height', stage.height)
        #  .attr('width', stage.width)
        #$("#stage svg rect")
        #  .attr('height', stage.height - 60)
        #  .attr('width', stage.width - 20)
        #force
        #  .size([stage.width, stage.height])
        #  .start();
      ), 250
    adjust()
    $(window).resize ->
      adjust()

  draw: ->
    console.log 'Drawing!'
    force
         .nodes(@model.get('canvas').nodes.toJSON())
         .links(@model.get('canvas').links.toJSON())
         .start()
    nodes = force.nodes()
    links = force.links()

    link = vis.selectAll(".link").data(links)

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






