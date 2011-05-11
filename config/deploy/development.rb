# DEVELOPMENT-specific deployment configuration
# please put general deployment config in config/deploy.rb

set :deploy_to, "/www/servers/#{application}"
set :host, "development"
set :domain, "development"
set :branch, "development"
set :rails_env, "development"
role :app, host
role :web, host
role :db, host, :primary => true