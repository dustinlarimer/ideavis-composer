mediator = require 'mediator'
template = require 'editor/views/templates/header'
View = require 'views/base/view'

module.exports = class HeaderView extends View
  autoRender: true
  el: '#header'
  template: template

  initialize: (data={}) ->
    super
    console.log '[-- Header view activated --]'
    @delegate 'change', '#canvas-attr-title', @update_canvas
    @delegate 'submit', 'form', @update_canvas

  update_canvas: ->
    _title = $('#canvas-attr-title').val() or 'Untitled'
    $('#canvas-attr-title').val(_title) if _title is 'Untitled'
    $(document).attr('title', _title);
    @model.save title: _title
    $('#canvas-attr-title').blur()
    return false