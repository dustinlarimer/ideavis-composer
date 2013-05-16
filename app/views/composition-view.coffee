View = require 'views/base/view'
template = require 'views/templates/composition'
Node = require 'models/node'
Link = require 'models/link'
Path = require 'models/path'
Text = require 'models/text'

module.exports = class CompositionEditorView extends View
  #autoRender: true
  el: '#editor'
  regions:
    '#controls': 'controls'
    '#stage': 'stage'
  template: template

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

  selected_node = null
  selected_link = null
  mousedown_link = null
  mousedown_node = null
  mouseup_node = null
  keydown_code = null

  shifty: ->
    console.log @model.get('canvas').fill

  keydown: ->
    console.log d3.event.keyCode
    switch d3.event.keyCode
      when 8, 46
        nodes.splice nodes.indexOf(selected_node), 1  if selected_node
        selected_node = null
        @draw
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
    console.log ':mousedown'
    unless mousedown_node?
      selected_node = null
      @draw

  mousemove: ->
    console.log ':mousemove'
  
  mouseup: (e) ->
    console.log ':mouseup'
    unless mouseup_node?
      #spot = d3.mouse(e.currentTarget)
      #new_node = new Node
      new_node =
        x: e.offsetX
        y: e.offsetY
        px: e.offsetX
        py: e.offsetY + 1
        r: 45
        f: "#FBFBFB"
        s: "#E5E5E5"
        sw: 3
        fixed: true
      console.log new_node
      #canvas_data?.nodes.push node
      @draw
      @resetMouseVars

  resetMouseVars: ->
    mousedown_node = null
    mouseup_node = null
    mousedown_link = null

  rescale: ->
    trans = d3.event.translate
    scale = d3.event.scale
    vis.attr "transform", "translate(" + trans + ")" + " scale(" + scale + ")"

  draw: ->
    console.log 'Drawing!'

  render: ->
    super
    console.log @model.get('canvas').nodes
    #@model.set({title: 'First Comp'})
    #@model.save()

    canvas_settings=
      fill   : @model.get('canvas').fill
      height : @model.get('canvas').height
      width  : @model.get('canvas').width
    canvas_data=
      nodes  : @model.get('canvas').nodes
      links  : @model.get('canvas').links

    node_drag = d3.behavior.drag()
      .on("dragstart", @dragstart)
      .on("drag", @dragmove)
      .on("dragend", @dragend);

    outer = d3.select("#stage")
      .append("svg:svg")
        .attr("width", canvas_settings.width)
        .attr("height", canvas_settings.height)
        .attr("pointer-events", "all")
    
    vis = outer.append('svg:g')
      #.on('mousemove', @mousemove)
      #.on('mousedown', @mousedown)
      #.on('mouseup', @mouseup)
    
    vis
      .append("svg:rect")
        .attr("fill", canvas_settings.fill)
        .attr("height", canvas_settings.height)
        .attr("width", canvas_settings.width)
        .attr('x', 10)
        .attr('y', 50)

    force = d3.layout.force()
      .charge(0) #-10
      .gravity(0)
      .nodes(canvas_data.nodes)
      .links(canvas_data.links)
      .size([canvas_settings.width, canvas_settings.height])
      .start()
    
    nodes = force.nodes()
    node  = vis.selectAll(".node")

    force.on "tick", ->
      vis.selectAll("circle")
        .attr("cx", (d) -> d.x)
        .attr("cy", (d) -> d.y)
    
    adjust = ->
      setInterval ( -> 
        stage.height = $('#stage').height()
        stage.width = $('#stage').width()
        $("#stage svg")
          .attr('height', stage.height)
          .attr('width', stage.width)
        $("#stage svg rect")
          .attr('height', stage.height - 60)
          .attr('width', stage.width - 20)
        force
          .size([stage.width, stage.height])
          .start();
      ), 250
    adjust()
    $(window).resize ->
      adjust()
