config =
  development:
    core_url: 'http://localhost:3000'
    image_url: 'http://localhost:3333/images/'
    api:
      base_url: 'http://localhost:3000'
  production:
    core_url: 'http://alpha.ideavis.co'
    image_url: 'http://ideavis-alpha-client.herokuapp.com/images/'
    api:
      base_url: 'http://alpha.ideavis.co'

switch window.location.hostname
  when 'alpha.ideavis.co', 'ideavis-alpha-core.herokuapp.com', 'ideavis-alpha-client.herokuapp.com'
    env = "production"
  else env = "development"

module.exports = config[env]