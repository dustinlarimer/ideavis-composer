mediator = require 'mediator'
View = require 'views/base/view'
template = require 'editor/views/templates/detail-palette-color'

module.exports = class DetailPaletteColorView extends View
  autoRender: true
  template: template
  tagName: 'li'