require File.dirname(__FILE__) + '/../spec_helper'

describe Messaging do

  class FakeClass
    include Messaging
  end

  describe "thread" do
    it "should create a new thread" do
      Messaging.instance_variable_set(:@message_thread, nil)
      t = mock("thread")
      Thread.should_receive(:new).and_return(t)
      Messaging.thread.should == t
    end
  end
  
  describe "amqp" do
    it "should create a new amqp" do
      Messaging.instance_variable_set(:@amqp, nil)
      a = mock("amqp")
      Messaging.should_receive(:open_connection).and_return(a)
      Messaging.amqp.should == a
    end
  end
  
  describe "open_connection" do
    it "should create a new open_connection" do
      Messaging.instance_variable_set(:@message_thread, nil)
      a = mock("amqp")
      Messaging.should_receive(:thread).and_return(true)
      AMQP.should_receive(:connect).and_return(a)
      Messaging.open_connection.should == a
    end
  end

  describe "channel" do
    it "should create a new channel" do
      c = mock("channel")
      MQ.should_receive(:new).and_return(c)
      Messaging.channel.should == c
    end
  end

  describe "queue" do
    it "should create a new queue" do
      c = mock("channel")
      q = mock("queue")
      Messaging.should_receive(:channel).and_return(c)
      c.should_receive(:queue).with("hello", :durable => true, :auto_delete => false).and_return(q)
      Messaging.queue("hello").should == q
    end

    it "should create a new queue that auto-deletes for worker" do
      c = mock("channel")
      q = mock("queue")
      Messaging.should_receive(:channel).and_return(c)
      c.should_receive(:queue).with("worker-1234", :durable => true, :auto_delete => true).and_return(q)
      Messaging.queue("worker-1234").should == q
    end

    it "should create a new queue that auto-deletes for worker starting with a letter" do
      c = mock("channel")
      q = mock("queue")
      Messaging.should_receive(:channel).and_return(c)
      c.should_receive(:queue).with("worker-a1234", :durable => true, :auto_delete => true).and_return(q)
      Messaging.queue("worker-a1234").should == q
    end
  end

  describe "delete" do
    it "should delete a queue" do
      q = mock("queue")
      Messaging.should_receive(:queue).with("name").and_return(q)
      q.should_receive(:delete).and_return(true)
      Messaging.delete("name").should == nil
    end
  end

  describe "subscribe" do
    it "should subscribe to a queue" do
      q = mock("queue")
      Messaging.should_receive(:queue).with("name").and_return(q)
      q.should_receive(:subscribe).and_yield("message")
      Messaging.subscribe("name") do |msg|
        msg.should == "message"
      end
    end
  end

  describe "publish" do
    it "should publish to a queue" do
      q = mock("queue")
      Messaging.should_receive(:queue).with("name").and_return(q)
      q.should_receive(:publish).with("msg", :persistent => true).and_return(true)
      Messaging.publish("name", "msg").should == true
    end
  end

  describe "server" do
    it "should set the server variable with default" do
      Messaging.server.should == "localhost"
    end

    it "should set the server variable" do
      Messaging.instance_variable_set(:@server, nil)
      Messaging.server("server").should == "server"
    end
  end
  
end
