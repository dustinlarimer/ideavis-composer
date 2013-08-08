Chaplin = require 'chaplin'
Model = require 'models/base/model'

module.exports = class Collection extends Chaplin.Collection
  url: ->
    url = super
    config.api.base_url + url

  # Use the project base model per default, not Chaplin.Model
  model: Model