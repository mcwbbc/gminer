#############################################################
#  Application
#############################################################

set :deploy_to, "/www/servers/processing/#{application}"
set :host, "host"
set :branch, "development"
set :rails_env, "processing"
role :app, host
role :web, host
role :db, host, :primary => true