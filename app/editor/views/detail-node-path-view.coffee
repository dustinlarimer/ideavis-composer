mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-node-path'

module.exports = class DetailNodePathView extends View
  autoRender: true
  template: template

  initialize: ->
    super
    @delegate 'change', 'input', @update_attributes
    #@delegate 'change', '#path-attribute-stroke-dasharray', @update_attributes
    @delegate 'click', '#path-attribute-shape button', @update_shape
    @delegate 'click', '#path-attribute-stroke-linecap button', @update_linecap

  render: ->
    super
    @$('#path-attribute-scale').val(@model.get('scale')*100)
    @$('#path-attribute-shape button[value="' + @model.get('shape') + '"]').addClass('active')
    if @model.get('shape') is 'none'
      @$('div.shape-controls:gt(0)').hide()
    else
      @$('div.shape-controls:gt(0)').show()
    
    _.each(@model.get('stroke_dasharray'), (d,i)=>
      @$('#path-attribute-stroke-dasharray input:eq(' + i + ')').val(d) unless d is 0
    )
    @$('#path-attribute-stroke-linecap button[value="' + @model.get('stroke_linecap') + '"]').addClass('active')

  update_attributes: =>
    _path=
      height: $('#path-attribute-height').val() or 100
      width:  $('#path-attribute-width').val() or 100
      rotate: $('#path-attribute-rotate').val() or 0
      fill:   $('#path-attribute-fill').val() or 'none'
      fill_opacity: $('#path-attribute-fill-opacity').val() or 100
      stroke: $('#path-attribute-stroke').val() or 'none'
      stroke_width: $('#path-attribute-stroke-width').val() or 0
      stroke_opacity: $('#path-attribute-stroke-opacity').val() or 100
      stroke_dash: []
    
    _.each($('#path-attribute-stroke-dasharray input'), (d,i)->
      _path.stroke_dash.push parseInt($(d).val()) or 0
    )

    @model.set _path

  update_shape: (e) =>
    _shape = $(e.currentTarget).val()
    if _shape is 'none'
      @$('div.shape-controls:gt(0)').hide()
    else
      @$('div.shape-controls:gt(0)').show()
    @model.set shape: _shape

  update_linecap: (e) =>
    _linecap = $(e.currentTarget).val()
    @model.set stroke_linecap: _linecap


