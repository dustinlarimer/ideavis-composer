View = require 'views/base/view'
template = require 'views/templates/canvas'

Node = require 'models/node'
NodeView = require 'views/node-view'

module.exports = class CanvasView extends View
  el: '#canvas'
  template: template
  regions:
    '#stage': 'stage'

  #listen:
  #'change model': -> console.log 'Model has changed'

  initialize: ->
    super
    console.log 'Initializing CanvasView'
    #@subscribeEvent 'canvas_attributes_updated', @applyCanvasAttributes
    @subscribeEvent 'canvas_rendered', @draw
    @subscribeEvent 'node_created', @draw
    
    @model.synced =>
      unless @rendered
        @render()
        @rendered = yes

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
    console.log '[...] Rendering CanvasView'
    
    outer = d3.select("#stage")
      .append('svg:svg')
      .attr('pointer-events', 'all');
    outer.append("svg:rect")
       .attr('id', 'canvas_background')
       .attr('fill', '#fff');
       #.attr('x', 10)
       #.attr('y', 50);
    vis = outer.append('svg:g')
       .attr('id', 'canvas_elements');
    
    force
         .charge(0)
         .gravity(0)
         .nodes(@model.nodes.models)
         .size([@model.get('canvas').width, @model.get('canvas').height])
         .start()
    nodes = force.nodes()
    node = vis.selectAll(".node")
    
    #@applyCanvasAttributes(@model)
    #console.log '»» CanvasView rendered!'
    @publishEvent 'canvas_rendered'

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

  $ ->
    adjust = ->
      setTimeout (->
        stage_height = $("#canvas").height()
        stage_width = $("#canvas").width()
        #('svg #canvas_elements').height()
        $("#stage svg").attr("height", stage_height).attr "width", stage_width
        $("#stage svg rect")
          .attr("height", stage_height)
          .attr("width", stage_width);
        force.size([stage_width, stage_height]).start()
      ), 250
    adjust()
    $(window).resize ->
      adjust()