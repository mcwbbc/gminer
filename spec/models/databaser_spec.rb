require File.dirname(__FILE__) + '/../spec_helper'

describe Databaser do

  describe "run" do
    it "should watch the queue" do
      d = Databaser.new
      d.should_receive(:watch_queue).and_return(true)
      d.run
    end
  end

  describe "watch_queue" do
    before(:each) do
      @d = Databaser.new
      @t = mock("thread", :null_object => true)
      Messaging.should_receive(:thread).and_return(@t)
      @t.should_receive(:join).and_return(true)
    end

    it "should save the term" do
      @message = {'command' => 'saveterm'}
      Messaging.should_receive(:subscribe).with("databaser-queue").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      OntologyTerm.should_receive(:persist).and_return(true)
      @d.watch_queue
    end

    it "should save the annotation" do
      @message = {'command' => 'saveannotation'}
      Messaging.should_receive(:subscribe).with("databaser-queue").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      Annotation.should_receive(:persist).and_return(true)
      @d.watch_queue
    end

    it "should save the closure" do
      @message = {'command' => 'saveclosure'}
      Messaging.should_receive(:subscribe).with("databaser-queue").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      AnnotationClosure.should_receive(:persist).and_return(true)
      @d.watch_queue
    end
  end

end
