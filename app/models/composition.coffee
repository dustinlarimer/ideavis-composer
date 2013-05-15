Model = require 'models/base/model'

module.exports = class Composition extends Model
  url: ->
    'http://localhost:3000/compositions/519108a5170d58b464000002'

  #urlPath: ->
  #  "/compositions/#{@get('_id')}"

  initialize: ->
    super

  render: ->
    console.log this._id

  parse: (response) ->
    console.log response
    console.log this.model