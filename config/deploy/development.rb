# DEVELOPMENT-specific deployment configuration
# please put general deployment config in config/deploy.rb

#use branch/dev to deploy to dev
  set :branch, "master"

#development
  set :domain, 'dev'
  role :app, domain
  role :web, domain
  role :db, domain, :primary => true
