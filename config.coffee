exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^vendor/
        'test/javascripts/test.js': /^test[\\/](?!vendor)/
        'test/javascripts/test-vendor.js': /^test[\\/](?=vendor)/
      order:
        # Files in `vendor` directories are compiled before other files
        # even if they aren't specified in order.before.
        before: [
          'vendor/scripts/console-polyfill.js',
          'vendor/scripts/d3-3.1.6.js',
          'vendor/scripts/d3.superforumla.v0.js',
          'vendor/scripts/jquery-1.9.1.js',
          'vendor/scripts/lodash.underscore.js',
          'vendor/scripts/backbone-1.0.0.js'
          'vendor/scripts/backbone-relational-0.8.5.js'
          'vendor/scripts/keymaster.js'
          'vendor/scripts/backbone.shortcuts.js'
        ]
        after: [
          'test/vendor/scripts/test-helper.js'
        ]

    stylesheets:
      joinTo:
        'stylesheets/app.css': /^(app|vendor)/
        'test/stylesheets/test.css': /^test/
      order:
        after: ['vendor/styles/helpers.css']

    templates:
      joinTo: 'javascripts/app.js'
