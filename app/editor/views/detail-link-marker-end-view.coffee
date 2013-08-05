mediator = require 'mediator'
template = require 'editor/views/templates/detail-link-marker-end'
View = require 'views/base/view'

module.exports = class DetailLinkMarkerEndView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    @delegate 'change', 'input', @update_attributes
    @delegate 'click', '#marker-end-attribute-type button', @update_type

  render: ->
    super
    @$('a > span[id^="icon-marker-"]').attr('id', 'icon-marker-' + @model.get('type'))

  update_attributes: ->
    #console.log 'updating marker'
    _marker=
      fill: $('#marker-end-attribute-fill').val() or 'none'
      fill_opacity: $('#marker-end-attribute-fill-opacity').val() or 100
      offset_x: $('#marker-end-attribute-offset-x').val() or 0
      width: $('#marker-end-attribute-width').val() or 0
    @model.set _marker

  update_type: (e) =>
    _type = $(e.currentTarget).val()
    @$('a > span[id^="icon-marker-"]').attr('id', 'icon-marker-' + _type)
    @$('.dropdown').removeClass('open')
    @model.set type: _type