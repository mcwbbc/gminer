namespace :deploy do
  desc "Deploy app"
  task :default do
    update
    restart
    cleanup
  end

  desc "Setup a GitHub-style deployment."
  task :setup, :except => { :no_release => true } do
    run "[ -d #{current_path} ] || git clone #{repository} #{current_path}"
    set (:shared_path) { File.join(deploy_to, shared_dir) }
    set :shared_children, %w(public/system log config bundled_gems pids)
    dirs = [shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard origin/#{branch}"
  end

  desc "Deploy and run migrations"
  task :migrations, :except => { :no_release => true } do
    update
    restart
    cleanup
  end

  desc "write the current version to REVISION"
  task :write_revision, :except => { :no_release => true } do
    run "cd #{current_path}; git rev-parse HEAD > #{current_path}/REVISION"
  end

  namespace :rollback do
    desc "Rollback"
    task :default do
      code
    end

    desc "Rollback a single commit."
    task :code, :except => { :no_release => true } do
      set :branch, "HEAD^"
      default
    end
  end

  # cleanup is a non-op with github deploy strat
  desc "Cleanup releases"
  task :cleanup do
  end

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
