namespace :configure do

  # after deploy, this will re-link the shared directories
  task :link_shared_directories do
    run <<-CMD
    rm -rf #{release_path}/datafiles && ln -nfs #{shared_path}/datafiles #{release_path}/datafiles &&
    rm -rf #{release_path}/public/media && ln -nfs #{shared_path}/media #{release_path}/public/media
    CMD
  end

  # after deploy, this will link the database.yml
  task :link_database_yml do
    run <<-CMD
      ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml
    CMD
  end
  
  # this will create shared directories for media and the index (sphinx)
  task :create_shared_directories do
    run <<-CMD
      mkdir -p -m 777 #{shared_path}/media && 
      mkdir -p -m 777 #{shared_path}/datafiles && 
      mkdir -p -m 777 #{shared_path}/gems && 
      mkdir -p -m 777 #{shared_path}/gems/gems && 
      mkdir -p -m 777 #{shared_path}/gems/specifications
    CMD
  end
end

namespace :bundlr do
  task :redeploy_gems, :roles => :app, :except => {:no_release => true} do
    run %{
      cd #{release_path} &&
      ln -nfs #{shared_path}/gems/gems #{release_path}/gems/gems &&
      ln -nfs #{shared_path}/gems/specifications #{release_path}/gems/specifications &&
      #{release_path}/bin/thor merb:gem:redeploy
      }
  end
end
