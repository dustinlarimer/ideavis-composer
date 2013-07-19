mediator = require 'mediator'
template = require 'editor/views/templates/detail-palette'
View = require 'views/base/view'

module.exports = class DetailPaletteView extends View
  autoRender: true
  template: template
  
  initialize: (data={}) ->
    super
    @delegate 'click', '.palette-grid canvas', @activate
    @delegate 'click', '.palette-grid a', @new

  new: (e) =>
    @activate(e)
    @$('.palette-overlay-panel').css('background', '#fff')
    
    _parent = @$(e.target).parents('ul').first()
    _last = $(_parent).find('li:last-child')[0]
    @$(_last).before('<li><canvas class="palette-preview"></canvas></li>')
    _length = @$(_parent).find('li').length
    _new = @$(_parent).find('li:eq(' + (_length-2) + ') canvas').addClass('new')
    
    @$('.palette-overlay input').val('').focus().keypress((e)=>
      setTimeout => 
        _color = @$('.palette-overlay input').val()
        @$('.palette-overlay-panel').css('background', _color) 
        @$(_new).css('background-color', _color).attr('title', _color)
      , 50
    )

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

  deactivate: (e) =>
    key.unbind 'command+c', 'palette'
    key.unbind 'control+c', 'palette'
    key.unbind 'enter', 'palette'
    key.unbind 'esc', 'palette'
    key.setScope ''
    
    code = e.keyCode
    
    _val = @$('.palette-overlay input').val()
    if _val is '' or _val.length < 7
      @$('.palette-grid li canvas.new').parent().remove()
      code = null
    
    setTimeout =>
      # 13 = enter = save
      # 27 = esc
      # 67 = copy
      if code is 67
        @$('.palette-overlay-panel').css('opacity', .96)
        @$('.palette-overlay').fadeOut(1000, =>
          @$('input, .palette-overlay-panel', this).remove()
          @$('.palette-overlay.active').removeClass('active').css('display', 'block')
        )
      else if code is 13
        @$('.palette-overlay').fadeOut(750, =>
          @$('input, .palette-overlay-panel', this).remove()
          @$('.palette-overlay.active').removeClass('active').css('display', 'block')
          #console.log '[-- UPDATE PALETTE WITH NEW/MODIFIED COLOR! --]'
        )
      else
        @$('.palette-overlay').fadeOut(250, =>
          @$('input, .palette-overlay-panel', this).remove()
          @$('.palette-overlay.active').removeClass('active').css('display', 'block')
        )
    , 50






