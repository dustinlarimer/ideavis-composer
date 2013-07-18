mediator = require 'mediator'
template = require 'editor/views/templates/detail-palette'
View = require 'views/base/view'

module.exports = class DetailPaletteView extends View
  autoRender: true
  template: template
  
  initialize: (data={}) ->
    super
    console.log 'Palette is loaded'

    @delegate 'click', '.palette-grid canvas', @activate

  activate: (e) =>
    key 'command+c', 'palette', @deactivate
    key 'control+c', 'palette', @deactivate
    key 'enter', 'palette', @deactivate
    key 'esc', 'palette', @deactivate
    key.setScope 'palette'
    key.filter = (e) ->
      tagName = (e.target || e.srcElement).tagName
      return !(tagName == 'SELECT' || tagName == 'TEXTAREA')
    
    val = $(e.currentTarget).attr('title')
    @$('.palette-overlay').addClass('active').html('<div class="palette-overlay-panel"></div><input class="span4" type="text" value="' + val + '"/>')
    @$('.palette-overlay-panel').css('background', val)
    @$('.palette-overlay input').focus()

  deactivate: =>
    key.unbind 'command+c', 'palette'
    key.unbind 'control+c', 'palette'
    key.unbind 'enter', 'palette'
    key.unbind 'esc', 'palette'
    key.setScope ''
    
    setTimeout =>
      @$('.palette-overlay input, .palette-overlay-panel').remove()
      @$('.palette-overlay').removeClass('active')
    , 50