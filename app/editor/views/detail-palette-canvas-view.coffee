mediator = require 'mediator'
#template = require 'editor/views/templates/detail-palette-canvas'
CollectionView = require 'views/base/collection-view'

DetailPaletteColorView = require 'editor/views/detail-palette-color-view'

module.exports = class DetailPaletteCanvasView extends CollectionView
  autoRender: true
  #template: template
  itemView: DetailPaletteColorView
  tagName: 'ul'
  className: 'palette-grid'

  initialize: ->
    super
    console.log @model
    @delegate 'click', 'a', @new_color
    @delegate 'click', 'canvas', @activate

  render: ->
    super
    console.log @collection
    $(@el).append('<li><a href="#"><i class="icon-plus"></i></a></li>')

  new_color: (e) =>
    @activate(e)    
    _parent = @$(e.target).parents('ul').first()
    _last = $(_parent).find('li:last-child')[0]
    @$(_last).before('<li><canvas class="palette-preview"></canvas></li>')
    _length = @$(_parent).find('li').length
    _new = $(_parent).find('li:eq(' + (_length-2) + ')').addClass('new')
    
    $('.palette-overlay input').val('').focus().keypress((e)=>
      setTimeout => 
        _color = $('.palette-overlay input').val()
        $('.palette-overlay-panel').css('background', _color) 
        @$('li.new').css('background-color', _color).attr('title', _color)
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

    _sel = $(e.currentTarget).parent()

    if @$('li').index(_sel) < (@$('li').length-1)
      @selection =  @collection.at(@$('li').index(_sel))
      console.log @selection

    _val = $(e.currentTarget).attr('title') or ''
    $(@el).parent().append('<div class="palette-overlay"><div class="palette-overlay-panel"></div><input class="span4" type="text" value="' + _val + '"/></div>')
    $('.palette-overlay-panel').css('background', _val or '#fff')
    $('.palette-overlay input').focus()


  deactivate: (e) =>
    key.unbind 'command+c', 'palette'
    key.unbind 'control+c', 'palette'
    key.unbind 'enter', 'palette'
    key.unbind 'esc', 'palette'
    key.setScope ''
    
    code = e.keyCode
    
    _val = $('.palette-overlay input').val()
    # strip out first char (#)
    # parseInt(_val)
    # 
    #if _val is '' or _val.length < 7
    #  @$('canvas.new').parent().remove()
    #  code = null
    
    setTimeout =>
      # 13 = enter = save
      # 27 = esc
      # 67 = copy
      if code is 67
        console.log 'Color copied!'
        $('.palette-overlay-panel').css('opacity', .96)
        $('.palette-overlay').fadeOut(1000, =>
          $('.palette-overlay').remove()
        )
      else if code is 13
        #console.log 'Color entered!'
        if _val
          _matching = @collection.where color: _val
          @collection.add color: _val if _matching.length is 0
          @$('li.new').remove()
        else
          @collection.remove(@selection)
        $('.palette-overlay').fadeOut(750, =>
          $('.palette-overlay').remove()
          console.log '[-- UPDATE PALETTE WITH NEW/MODIFIED COLOR! --]'
        )
      else
        console.log 'escape!'
        $('.palette-overlay').fadeOut(250, =>
          $('.palette-overlay').remove()
        )
    , 50
