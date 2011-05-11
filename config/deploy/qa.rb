#############################################################
#  Application
#############################################################

set :deploy_to, "/www/servers/#{application}_qa"
set :host, "development"
set :branch, "development"
set :rails_env, "production"
role :app, host
role :web, host
role :db, host, :primary => true