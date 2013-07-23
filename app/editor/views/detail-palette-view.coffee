mediator = require 'mediator'
template = require 'editor/views/templates/detail-palette'
View = require 'views/base/view'

DetailPaletteCanvasView = require 'editor/views/detail-palette-canvas-view'

module.exports = class DetailPaletteView extends View
  autoRender: true
  template: template
  regions: 
    '.user-palettes'  : 'user_palettes'
    '.canvas-palette' : 'canvas_palette'
  
  initialize: (data={}) ->
    super
    @delegate 'click', '.user-palettes li canvas', @activate
    @delegate 'click', '.user-palettes a', @new
    @delegate 'click', '.demo-palette-overlay .palette-overlay-panel', @deactivate

  render: ->
    super
    @subview 'canvas-palette', new DetailPaletteCanvasView collection: mediator.canvas.colors, region: 'canvas_palette'

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
    key 'command+c', 'demo_palette', @deactivate
    key 'control+c', 'demo_palette', @deactivate
    key 'enter', 'demo_palette', @deactivate
    key 'esc', 'demo_palette', @deactivate
    key.setScope('demo_palette')
    
    val = $(e.currentTarget).attr('title')
    @$('.demo-palette-overlay').addClass('active').html('<div class="palette-overlay-panel"></div><input class="span4 input-palette" type="text" value="' + val + '"/>')
    @$('.palette-overlay-panel').css('background', val)
    @$('.demo-palette-overlay input').focus()

  deactivate: (e) =>
    key.unbind 'command+c', 'demo_palette'
    key.unbind 'control+c', 'demo_palette'
    key.unbind 'enter', 'demo_palette'
    key.unbind 'esc', 'demo_palette'
    key.setScope('editor')
    
    code = e.keyCode or ''
    
    _val = @$('.demo-palette-overlay input').val() or ''
    if _val is '' or _val.length < 7
      @$('.user-palettes li canvas.new').parent().remove()
      code = null
    
    setTimeout =>
      # 13 = enter = save
      # 27 = esc
      # 67 = copy
      if code is 67
        @$('.palette-overlay-panel').css('opacity', .96)
        $('.demo-palette-overlay').fadeOut(1000, =>
          $('.demo-palette-overlay input, .demo-palette-overlay .palette-overlay-panel').remove()
          $('.demo-palette-overlay').removeClass('active') #.css('display', 'block')
        )
      else if code is 13
        $('.demo-palette-overlay').fadeOut(750, =>
          $('.demo-palette-overlay input, .demo-palette-overlay .palette-overlay-panel').remove()
          $('.demo-palette-overlay').removeClass('active') #.css('display', 'block')
          #console.log '[-- UPDATE PALETTE WITH NEW/MODIFIED COLOR! --]'
        )
      else
        $('.demo-palette-overlay').fadeOut(250, =>
          $('.demo-palette-overlay input, .demo-palette-overlay .palette-overlay-panel').remove()
          $('.demo-palette-overlay').removeClass('active') #.css('display', 'block')
        )
    , 50






