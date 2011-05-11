namespace :distribute do

  desc "Setup rabbitmq vhost/users"
  task(:config => :environment) do
    environment = ENV['RAILS_ENV'] || 'development'
    puts "environment: #{environment}"
    puts `rabbitmqctl add_vhost /gminer-#{environment}`
    # create 'gminer' user, give them each the password 'gminer'
    %w[gminer].each do |agent|
      puts `rabbitmqctl add_user #{agent} gminer`
    end
    puts `rabbitmqctl set_permissions -p /gminer-#{environment} gminer ".*" ".*" ".*"`
  end

end
