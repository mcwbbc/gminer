namespace :distribute do

  desc "Run the scheduler"
  task(:scheduler, :workers, :needs => :environment) do |t, args| 
    workers = args[:workers] ? args[:workers] : 5
    scheduler = Scheduler.new
    scheduler.run(workers)
  end

  desc "Run the processor"
  task(:processor, :needs => :environment) do |t, args|  
    processor = Processor.new
    processor.run
  end

  desc "Run the databaser"
  task(:databaser, :needs => :environment) do |t, args|  
    databaser = Databaser.new
    databaser.run
  end

  desc "Setup rabbitmq vhost/users"
  task(:config, :needs => :environment) do |t, args|  
    puts `sudo rabbitmqctl add_vhost /gminer`
    # create 'gminer' user, give them each the password 'gminer'
    %w[gminer].each do |agent|
      puts `sudo rabbitmqctl add_user #{agent} gminer`
    end
    puts `sudo rabbitmqctl set_permissions -p /gminer gminer ".*" ".*" ".*"`
  end

end
