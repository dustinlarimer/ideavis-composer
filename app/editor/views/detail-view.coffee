mediator = require 'mediator'
template = require 'editor/views/templates/detail'
View = require 'views/base/view'

DetailNodeView = require 'editor/views/detail-node-view'

module.exports = class DetailView extends View
  autoRender: true
  el: '#detail'
  template: template
  regions: 
    '#detail-tray': 'tray'
  
  initialize: ->
    super
    console.log '[-- Detail view activated --]'
    @subview 'detail-tray', null
    @subscribeEvent 'activate_detail', @activate_detail
    @subscribeEvent 'deactivate_detail', @deactivate_detail

  activate_detail: (model) ->
    @subview 'detail-tray', new DetailNodeView model: model, region: 'tray'

  deactivate_detail: ->
    @removeSubview 'detail-tray'