#############################################################
#	Application
#############################################################

set :application, 'gminer'
set :deploy_to, "/www/servers/#{application}"

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
set :use_sudo, false
set :keep_releases, 2
set :stages, %w(development production)
set :default_stage, "development"

#############################################################
#	Includes
#############################################################

require 'capistrano/ext/multistage'
load 'config/deploy/configure'

#############################################################
#	Git
#############################################################

set :scm, :git
set :repository,  "git@github.com:mcwbbc/#{application}.git"
set :deploy_via, :remote_cache

#############################################################
#	Servers
#############################################################

set :user, 'rubyweb'

#############################################################
#	Post Deploy Hooks
#############################################################

namespace :deploy do

  desc "Runs after every successful deployment" 
  task :after_default do
    cleanup #removes the old deploys
  end

  after "deploy:setup", "configure:create_shared_directories"
  after "deploy:update_code", "configure:link_shared_directories"
  after "deploy:update_code", "configure:link_database_yml"
  after "deploy:symlink", "bundlr:redeploy_gems"

end

#############################################################
#	Passenger
#############################################################

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

#############################################################
#	Other Tasks
#############################################################

