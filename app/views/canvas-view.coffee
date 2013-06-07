mediator = require 'mediator'
View = require 'views/base/view'
template = require 'views/templates/canvas'

try EditorView = require 'editor/views/editor-view'

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
    $(window).on 'resize', @refresh_canvas
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
  node  = undefined

  viewport=
    height: window.innerHeight
    width: window.innerWidth
  
  bounds=
    height: undefined
    width: undefined
    x: undefined
    y: undefined

  rescale: ->
    trans = d3.event.translate
    scale = d3.event.scale
    vis.attr "transform", "translate(" + trans + ")" + " scale(" + scale + ")"

  render: ->
    super
    console.log 'Rendering CanvasView [...]'
    
    outer = d3.select("#stage")
      .append('svg:svg')
      .attr('pointer-events', 'all');
    
    outer.append("svg:rect")
      .attr('id', 'canvas_background')
      .attr('fill', '#fff');
    
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
    
    if EditorView?
      editorView = new EditorView container: @el, model: @model
      @subview 'editor', editorView

  #applyCanvasAttributes: (canvas) ->
  #  console.log 'applyCanvasAttributes()'
  #  outer
  #    .attr('height', canvas.attributes.height)
  #    .attr('width', canvas.attributes.width)
  #  vis.select('rect')
  #    .attr('fill', canvas.attributes.fill)
  #    .attr('height', canvas.attributes.height)
  #    .attr('width', canvas.attributes.width)
  #  force
  #    .size([canvas.attributes.width, canvas.attributes.height])
  #    .start()

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
    bounds.x = d3.extent(force.nodes(), (d) -> return d.attributes.x )
    bounds.y = d3.extent(force.nodes(), (d) -> return d.attributes.y )
    bounds.height = Math.max((viewport.height - 40), (bounds.y[1]+100))
    bounds.width = Math.max((viewport.width), (bounds.x[1]+100))

  refresh_canvas: ->
    console.log '⟲ Refreshing canvas'
    console.log 'bounds.x: ' + bounds.x
    console.log 'bounds.y: ' + bounds.y
    console.log 'bounds.height: ' + bounds.height
    console.log 'bounds.width: ' + bounds.width

    $("#canvas, #stage, #stage svg, #stage svg rect")
      .attr("height", bounds.height)
      .attr("width", bounds.width);    
    force
      .size([bounds.width, bounds.height])
      .start()
