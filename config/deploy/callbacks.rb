namespace :deploy do

  desc "expand the gems"
  task :gems, :roles => :web, :except => { :no_release => true } do
    run "cd #{current_path}; bundle install --gemfile Gemfile --deployment --without cucumber development test"
  end

  desc 'Compile, bundle and minify the JS and CSS files'
  task :precache_assets, :roles => :app do
    root_path = File.expand_path(File.dirname(__FILE__) + '/../..')
    sass_path = "#{root_path}/public/stylesheets/sass/"
    css_path = "#{root_path}/public/stylesheets/"
    run_locally "bundle exec #{root_path}/vendor/bundle/ruby/1.9.1/bin/sass --update #{sass_path}:#{css_path}"
    assets_path = "#{root_path}/public/assets"
    run_locally "bundle exec #{root_path}/vendor/bundle/ruby/1.9.1/bin/jammit"
    top.upload assets_path, "#{current_path}/public", :via => :scp, :recursive => true
  end

end


# Capistrano Recipes for managing delayed_job
#
# Add these callbacks to have the delayed_job process restart when the server
# is restarted:
#
#   after "deploy:stop",    "delayed_job:stop"
#   after "deploy:start",   "delayed_job:start"
#   after "deploy:restart", "delayed_job:restart"


namespace :delayed_job do
  desc "Stop the delayed_job process"
  task :stop, :roles => :app do
    run "kill -9 $(ps aux | grep -v grep | grep '[d]elayed_job\.#{application}_#{stage}' | awk '{print $2}')"
    run "sleep 1"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job stop"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job start -i #{application}_#{stage}"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :app do
    run "kill -9 $(ps aux | grep -v grep | grep '[d]elayed_job\.#{application}_#{stage}' | awk '{print $2}')"
    run "sleep 1"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job restart -i #{application}_#{stage}"
  end
end