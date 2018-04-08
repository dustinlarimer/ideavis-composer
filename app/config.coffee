config =
  development:
    core_url: 'http://localhost:3000'
    image_url: 'http://localhost:3333/images/'
    api:
      base_url: 'http://localhost:3000'
  production:
    core_url: 'https://ideavis-alpha-core.herokuapp.com'
    image_url: 'https://ideavis-alpha-client.herokuapp.com/images/'
    api:
      base_url: 'https://ideavis-alpha-core.herokuapp.com'

switch window.location.hostname
  when 'ideavis-alpha-core.herokuapp.com', 'ideavis-alpha-client.herokuapp.com'
    env = "production"
  else env = "development"

module.exports = config[env]
