Collection = require 'models/base/collection'
Link = require 'models/link'

module.exports = class Links extends Collection
  model: Link

  initialize: ->
    super