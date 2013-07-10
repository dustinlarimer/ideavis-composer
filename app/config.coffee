config =
  development:
    core_url: 'http://localhost:3000'
    image_url: 'http://localhost:3333/images/'
    api:
      base_url: 'http://localhost:3000'
  production:
    core_url: 'http://larimer-canvas-demo.herokuapp.com'
    image_url: 'http://larimer-canvas-client.herokuapp.com/images/'
    api:
      base_url: 'http://larimer-canvas-demo.herokuapp.com'

switch window.location.hostname
  when 'http://larimer-canvas-demo.herokuapp.com', 'http://larimer-canvas-client.herokuapp.com'
    env = "production"
  else env = "development"

module.exports = config[env]