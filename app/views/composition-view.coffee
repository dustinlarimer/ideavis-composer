View = require 'views/base/view'
template = require 'views/templates/composition'

module.exports = class CompositionEditorView extends View
  autoRender: true
  el: '#editor'
  regions:
    '#controls': 'controls'
    '#stage': 'stage'
  template: template

  initialize: ->
    super
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

  shortcuts:
    'shift+t' : 'shifty'

  stage:
    'width' : 600
    'width' : 900
    'fill'  : '#fff'

  shifty: =>
    console.log 'Shifty! shift + t shortcut pressed!'

  render: ->
    super
    
    selected_node = null
    selected_link = null
    mousedown_link = null
    mousedown_node = null
    mouseup_node = null
    keydown_code = null
    
    outer = d3.select("#stage")
      .append("svg:svg")
        .attr("width", this.stage.width)
        .attr("height", this.stage.height)
        .attr("pointer-events", "all")
    
    vis = outer.append('svg:g')
      .on("dblclick.zoom", null)
      .append('svg:g')
        #.on("mousemove", mousemove)
        #.on("mousedown", mousedown)
        #.on("mouseup", mouseup)

    vis
      .append("svg:rect")
        .attr("fill", this.stage.fill)
        .attr("height", this.stage.height)
        .attr("width", this.stage.width)
        .attr('x', 10)
        .attr('y', 50)

    force = d3.layout.force()
      .charge(0) #-10
      .gravity(0)
      #.nodes(user_data.nodes)
      #.links(user_data.links)
      .size([this.stage.width, this.stage.height])
      .start()
    
    nodes = force.nodes()
    node  = vis.selectAll(".node")

    force.on "tick", ->
      vis.selectAll("circle")
        .attr("cx", (d) -> d.x)
        .attr("cy", (d) -> d.y)
    
    adjust = ->
      setInterval ( -> 
        this.stage.height = $('#stage').height()
        this.stage.width = $('#stage').width()
        $("#stage svg")
          .attr('height', this.stage.height)
          .attr('width', this.stage.width)
        $("#stage svg rect")
          .attr('height', this.stage.height - 60)
          .attr('width', this.stage.width - 20)
        force
          .size([this.stage.width, this.stage.height])
          .start();
      ), 250
    adjust()
    $(window).resize ->
      adjust()


