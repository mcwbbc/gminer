require 'rubygems'
require 'mq'

module Messaging
  trap("TERM") do
    puts "Received terminate"
    queue(@subscribed_queue_name).delete { amqp.close { EM.stop } } 
    exit
  end

  trap("INT") do
    puts "Received interrupt"
    queue(@subscribed_queue_name).delete { amqp.close { EM.stop } } 
    exit
  end

  def self.thread
    @message_thread ||= Thread.new { EM.run }
  end

  def self.amqp
    @amqp ||= open_connection
  end

  def self.open_connection
    thread
    amqp = AMQP.connect(
            :user => 'gminer',
            :pass => 'gminer',
            :server => server,
            :vhost => '/gminer'
            )
    puts "Connected to AMQP"
    amqp
  end

  def self.channel
    @channel ||= MQ.new(amqp)
  end

  def self.queue(name)
    channel.queue(name, :durable => true, :auto_delete => !!name.match(/worker-.+/))
  end

  def self.delete(name)
    result = queue(name).delete
    puts "deleted #{name} : #{result}"
  end

  def self.subscribe(name)
    queue(name).subscribe do |msg|
      yield msg
    end
    puts "subscribed to #{name}"
  end

  def self.publish(name, msg)
    queue(name).publish(msg, :persistent => true)
  end

  def self.server(server='localhost')
    @server ||= server
  end

end
