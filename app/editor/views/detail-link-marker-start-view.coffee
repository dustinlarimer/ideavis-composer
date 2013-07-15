mediator = require 'mediator'
template = require 'editor/views/templates/detail-link-marker-start'
View = require 'views/base/view'

module.exports = class DetailLinkMarkerStartView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    @delegate 'change', 'input', @update_attributes
    @delegate 'change', 'select', @update_attributes

  render: ->
    super
    @$('#marker-start-attribute-type').val(@model.get('type'))

  update_attributes: ->
    console.log 'updating marker'
    _marker=
      type: $('#marker-start-attribute-type').val()
      offset_x: $('#marker-start-attribute-offset-x').val() or 0
      width: $('#marker-start-attribute-width').val() or 0
      fill: $('#marker-start-attribute-fill').val() or 'none'
      fill_opacity: $('#marker-start-attribute-fill-opacity').val() or 100
      stroke_width: $('#marker-start-attribute-stroke-width').val() or 0
      stroke: $('#marker-start-attribute-stroke').val() or 'none'
      stroke_opacity: $('#marker-start-attribute-stroke-opacity').val() or 100
    @model.set _marker