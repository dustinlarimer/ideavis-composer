mediator = require 'mediator'
template = require 'editor/views/templates/detail'
View = require 'views/base/view'

Node = require 'models/node'
Link = require 'models/link'

DetailNodeView = require 'editor/views/detail-node-view'
DetailLinkView = require 'editor/views/detail-link-view'

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
    @deactivate_detail()
    if model instanceof Node
      @subview 'detail-tray', new DetailNodeView model: model, region: 'tray'
    else if model instanceof Link
      @subview 'detail-tray', new DetailLinkView model: model, region: 'tray'

  deactivate_detail: ->
    @removeSubview 'detail-tray'