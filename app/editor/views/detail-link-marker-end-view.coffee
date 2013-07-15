mediator = require 'mediator'
template = require 'editor/views/templates/detail-link-marker-end'
View = require 'views/base/view'

module.exports = class DetailLinkMarkerEndView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    @delegate 'change', 'input', @update_attributes
    @delegate 'change', 'select', @update_attributes

  render: ->
    super
    @$('#marker-end-attribute-type').val(@model.get('type'))

  update_attributes: ->
    console.log 'updating marker'
    _marker=
      type: $('#marker-end-attribute-type').val()
      offset_x: $('#marker-end-attribute-offset-x').val() or 0
      width: $('#marker-end-attribute-width').val() or 0
      fill: $('#marker-end-attribute-fill').val() or 'none'
      fill_opacity: $('#marker-end-attribute-fill-opacity').val() or 100
      stroke_width: $('#marker-end-attribute-stroke-width').val() or 0
      stroke: $('#marker-end-attribute-stroke').val() or 'none'
      stroke_opacity: $('#marker-end-attribute-stroke-opacity').val() or 100
    @model.set _marker