View = require 'views/base/view'
template = require 'views/templates/composition'

module.exports = class CompositionEditorView extends View
  #autoRender: true
  el: '#editor'
  regions:
    '#controls': 'controls'
    '#stage': 'stage'
  template: template

  initialize: ->
    super
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()
    @model.synced =>
      unless @rendered
        @render()
        @rendered = yes

  shortcuts:
    'shift+t' : 'shifty'

  shifty: =>
    console.log @model.get('canvas').fill

  render: ->
    super
    
    canvas_settings:
      fill   : @model.get('canvas').fill
      height : @model.get('canvas').height
      width  : @model.get('canvas').width
    
    selected_node = null
    selected_link = null
    mousedown_link = null
    mousedown_node = null
    mouseup_node = null
    keydown_code = null
    
    outer = d3.select("#stage")
      .append("svg:svg")
        .attr("width", @model.get('canvas').width)
        .attr("height", @model.get('canvas').height)
        .attr("pointer-events", "all")
    
    vis = outer.append('svg:g')
      .on("dblclick.zoom", null)
      #.append('svg:g')
      #.on("mousemove", mousemove)
      #.on("mousedown", mousedown)
      #.on("mouseup", mouseup)
    
    vis
      .append("svg:rect")
        .attr("fill", @model.get('canvas').fill)
        .attr("height", @model.get('canvas').height)
        .attr("width", @model.get('canvas').width)
        .attr('x', 10)
        .attr('y', 50)

    force = d3.layout.force()
      .charge(0) #-10
      .gravity(0)
      .nodes(@model.get('canvas').nodes)
      .links(@model.get('canvas').links)
      .size([@model.get('canvas').width, @model.get('canvas').height])
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


