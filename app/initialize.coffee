Application = require 'application'

# Initialize the application on DOM ready event.
$ ->
  (new Application).initialize()
  FastClick.attach(document.body)