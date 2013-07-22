mediator = require 'mediator'
template = require 'editor/views/templates/detail'
View = require 'views/base/view'

Node = require 'models/node'
Link = require 'models/link'
Axis = require 'models/axis'

DetailPaletteView = require 'editor/views/detail-palette-view'
DetailCanvasView = require 'editor/views/detail-canvas-view'
DetailNodeView = require 'editor/views/detail-node-view'
DetailLinkView = require 'editor/views/detail-link-view'
DetailAxisView = require 'editor/views/detail-axis-view'

module.exports = class DetailView extends View
  autoRender: true
  el: '#detail-wrapper'
  template: template
  regions: 
    '#detail-palette' : 'palette'
    '#detail-tray'    : 'tray'
  
  initialize: ->
    super
    console.log '[-- Detail view activated --]'
    @subview 'detail-tray', null
    @subscribeEvent 'activate_detail', @activate_selection
    @subscribeEvent 'deactivate_detail', @deactivate_selection

  render: ->
    super
    @subview 'detail-palette', new DetailPaletteView region: 'palette'
    @activate_master()

  activate_master: =>
    @subview 'detail-tray', new DetailCanvasView region: 'tray'

  activate_selection: (model) =>
    @removeSubview 'detail-tray'
    if model instanceof Node
      @subview 'detail-tray', new DetailNodeView model: model, region: 'tray'
    else if model instanceof Link
      @subview 'detail-tray', new DetailLinkView model: model, region: 'tray'
    else if model instanceof Axis
      @subview 'detail-tray', new DetailAxisView model: model, region: 'tray'
    d3.selectAll('g.axis text').transition().ease('linear').style('opacity', 1)

  deactivate_selection: =>
    @removeSubview 'detail-tray'
    @activate_master()