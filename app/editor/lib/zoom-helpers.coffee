mediator = require 'mediator'

zoom_helpers =
  get_coordinates: (e) =>
    
    _offset = $('#canvas_elements')[0].getBBox()
    _parent = $('#canvas_elements')[0].getBoundingClientRect()
    _x = null
    _y = null
    _scale = mediator.offset[1] or 1
    
    if _parent.left > 50
      _x = (_offset.x*_scale) - (_parent.left-50) + (e.clientX-50)
    else
      if _offset.x > 0
        _x = Math.abs(_parent.left-50) + (e.clientX-50) + Math.abs(_offset.x*_scale)
      else
        _x = Math.abs(_parent.left-50) + (e.clientX-50) - Math.abs(_offset.x*_scale)

    if _parent.top > 50
      _y = (_offset.y*_scale) - (_parent.top-50) + (e.clientY-50)
    else
      if _offset.y > 0
        _y = Math.abs(_parent.top-50) + (e.clientY-50) + Math.abs(_offset.y*_scale)
      else
        _y = Math.abs(_parent.top-50) + (e.clientY-50) - Math.abs(_offset.y*_scale)
    
    _x = _x / _scale
    _y = _y / _scale
    return {x: _x, y: _y}

module.exports = zoom_helpers