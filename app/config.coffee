config =
  development:
    core_url: 'http://localhost:3000'
    image_url: 'http://localhost:3333/images/'
    api:
      base_url: 'http://localhost:3000'
  production:
    core_url: ''
    image_url: ''
    api:
      base_url: ''

switch window.location.hostname
  when 'sub.domain.com', 'sub2.domain.com'
    env = "production"
  else env = "development"

module.exports = config[env]