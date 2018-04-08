exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'javascripts/editor.js'           : /^app(\/|\\)editor/
        'javascripts/app.js'              : /^app(\/|\\)(?!editor)/
        'javascripts/vendor.js'           : /^vendor/
        'test/javascripts/test.js'        : /^test[\\/](?!vendor)/
        'test/javascripts/test-vendor.js' : /^test[\\/](?=vendor)/
      order:
        before: [
          'vendor/scripts/console-polyfill.js',
          'vendor/scripts/d3-3.2.6.js',
          'vendor/scripts/jquery-1.9.1.js',
          'vendor/scripts/lodash.underscore.js',
          'vendor/scripts/backbone-1.0.0.js'
          'vendor/scripts/backbone-firebase.js'
          'vendor/scripts/keymaster.js'
        ]
        after: [
          'test/vendor/scripts/test-helper.js'
        ]

    stylesheets:
      joinTo:
        'stylesheets/editor.css'          : /^app(\/|\\)editor/
        'stylesheets/app.css'             : /^(app|vendor)(\/|\\)(?!editor)/
        #'stylesheets/app.css'            : /^(app|vendor)/
        'test/stylesheets/test.css'       : /^test/
      order:
        after: ['vendor/styles/helpers.css']

    templates:
      joinTo:
        'javascripts/editor.js'           : /^app(\/|\\)editor/
        'javascripts/app.js'              : /^app(\/|\\)(?!editor)/