#############################################################
#	Application
#############################################################

set :application, 'gminer'

#############################################################
#	Git
#############################################################

set :scm, :git
set :repository,  "git@github.com:mcwbbc/#{application}-public.git"
set :deploy_via, :fast_remote_cache
set :copy_exclude, %w(.git doc test)

#############################################################
#	Servers
#############################################################

set :user, "rubyweb"

#############################################################
#	Includes
#############################################################

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
set :use_sudo, false
set :keep_releases, 2
before "deploy", "deploy:check_revision"

after "deploy:update", "deploy:link_config"
after "deploy:update", "deploy:link_datafiles"
after "deploy:update", "deploy:cleanup"

# Customize the deployment
set :tag_on_deploy, false # turn off deployment tagging, we have our own tagging strategy

#############################################################
#	Post Deploy Hooks
#############################################################

# directories to preserve between deployments
# set :asset_directories, ['public/system/logos', 'public/system/uploads']

# re-linking for config files on public repos  
namespace :deploy do
  desc "Re-link config files"
  task :link_config, :roles => :app do
    run "rm -rf #{current_path}/config/database.yml && ln -nsf #{shared_path}/database.yml #{current_path}/config/database.yml"
  end

  # after deploy, this will re-link the shared directories
  desc "Re-link datafiles directory"
  task :link_datafiles, :roles => :app do
    run "ln -nsf /datafiles #{current_path}/datafiles"
  end
end
  
namespace :deploy do
  desc "Make sure there is something to deploy"
  task :check_revision, :roles => [:web] do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
      puts ""
      puts "  [1;33m**************************************************[0m"
      puts "  [1;33m* WARNING: HEAD is not the same as origin/#{branch} *[0m"
      puts "  [1;33m**************************************************[0m"
      puts ""
 
      exit
    end
  end
end    

#############################################################
#	Other Tasks
#############################################################

namespace :deploy do
  namespace :web do
    desc "Serve up a custom maintenance page."
    task :disable, :roles => :web do
      require 'erb'
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }

      reason      = ENV['REASON']
      deadline    = ENV['UNTIL']

      template = File.read("app/views/layouts/maintenance.html.erb")
      page = ERB.new(template).result(binding)
      
      put page, "#{shared_path}/system/maintenance.html", 
                :mode => 0644
    end
  end
end
