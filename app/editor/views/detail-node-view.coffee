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
    @delegate 'change', '#node-attributes input', @update_attributes
    @delegate 'click', 'input', (e)-> @$(e.target).select()

  listen:
    'change model': 'update_view'

  render: ->
    super
    @subview 'detail-node-paths', new DetailNodePathsView collection: @model.paths, region: 'paths'
    @subview 'detail-node-texts', new DetailNodeTextsView collection: @model.texts, region: 'texts'

  update_attributes: =>
    console.log 'updating attributes'
    _x = parseInt($('#node-attribute-x').val())
    _y = parseInt($('#node-attribute-y').val())
    _rotate = parseInt($('#node-attribute-rotate').val())
    _opacity = parseInt($('#node-attribute-opacity').val())
    @model.save({x: _x, y: _y, rotate: _rotate, opacity: _opacity})

  update_view: =>
    $('#node-attribute-x').val(@model.get('x'))
    $('#node-attribute-y').val(@model.get('y'))