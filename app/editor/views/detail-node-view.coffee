mediator = require 'mediator'
template = require 'editor/views/templates/detail-node'
View = require 'views/base/view'

DetailNodePathsView = require 'editor/views/detail-node-paths-view'
DetailNodeTextsView = require 'editor/views/detail-node-texts-view'

module.exports = class DetailNodeView extends View
  autoRender: true
  template: template
  regions:
    '#node-paths': 'paths'
    '#node-texts': 'texts'

  initialize: (data={}) ->
    super
    console.log 'Initialized DetailNodeView for Node #' + @model.id
    console.log @model
    
    @delegate 'change', '#node-attrs input', @update_attr

  listen:
    'change model': 'render'

  render: ->
    super
    @subview 'detail-node-paths', new DetailNodePathsView collection: @model.paths, region: 'paths'
    @subview 'detail-node-texts', new DetailNodeTextsView collection: @model.texts, region: 'texts'

  update_attr: =>
    _x = $('#node-attr-x').val()
    _y = $('#node-attr-y').val()
    _rotate = $('#node-attr-rotate').val()
    _scale = $('#node-attr-scale').val()
    @model.set x: _x, y: _y, rotate: _rotate, scale: _scale