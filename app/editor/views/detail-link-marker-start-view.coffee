mediator = require 'mediator'
template = require 'editor/views/templates/detail-link-marker-start'
View = require 'views/base/view'

module.exports = class DetailLinkMarkerStartView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    @delegate 'change', 'input', @update_attributes
    @delegate 'click', '#marker-start-attribute-type button', @update_type

  render: ->
    super
    @$('a > span[id^="icon-marker-"]').attr('id', 'icon-marker-' + @model.get('type'))

  update_attributes: ->
    #console.log 'updating marker'
    _marker=
      fill: $('#marker-start-attribute-fill').val() or 'none'
      fill_opacity: $('#marker-start-attribute-fill-opacity').val() or 100
      offset_x: $('#marker-start-attribute-offset-x').val() or 0
      width: $('#marker-start-attribute-width').val() or 0
    @model.set _marker

  update_type: (e) =>
    _type = $(e.currentTarget).val()
    @$('a > span[id^="icon-marker-"]').attr('id', 'icon-marker-' + _type)
    @$('.dropdown').removeClass('open')
    @model.set type: _type