#############################################################
#  Application
#############################################################

set :deploy_to, "/www/servers/staging/#{application}"
set :host, "host"
set :branch, "staging"
set :rails_env, "staging"
role :app, host
role :web, host
role :db, host, :primary => true