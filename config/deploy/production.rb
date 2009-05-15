# PRODUCTION-specific deployment configuration
# please put general deployment config in config/deploy.rb

#use trunk to deploy to production
  set :branch, "master"

#production
  set :domain, 'prod'
  role :app, domain
  role :web, domain
  role :db, domain, :primary => true
