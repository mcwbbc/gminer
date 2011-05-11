namespace :deploy do
  # override default tasks to make capistrano happy
  desc "Start Passenger"
  task :start do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Restart Passenger"
  task :restart do
    stop
    start
  end

  desc "Stop Passenger"
  task :stop do
  end
end