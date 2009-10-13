require File.dirname(__FILE__) + '/../spec_helper'

describe Processor do

  describe "run" do
    before(:each) do
      @p = Processor.new
      @t = mock("thread")
      Messaging.should_receive(:publish).with("scheduler-queue", "{\"command\":\"alive\",\"worker_key\":\"1234\"}").and_return(true)
      Messaging.should_receive(:thread).and_return(@t)
      @t.should_receive(:join).and_return(true)
      @p.stub!(:worker_key).and_return("1234")
    end

    it "should send prepare" do
      @message = {'command' => 'prepare'}
      Messaging.should_receive(:subscribe).with("worker-1234").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      Messaging.should_receive(:publish).with("scheduler-queue", "{\"command\":\"ready\",\"worker_key\":\"1234\"}").and_return(true)
      @p.run
    end

    it "should send working" do
      @message = {'command' => 'job', 'job_id' => 1}
      Messaging.should_receive(:subscribe).with("worker-1234").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      Messaging.should_receive(:publish).with("scheduler-queue", "{\"command\":\"working\",\"job_id\":1,\"worker_key\":\"1234\"}").and_return(true)
      @p.should_receive(:process_job).with(@message)
      @p.run
    end

    it "should shutdown" do
      @message = {'command' => 'shutdown'}
      Messaging.should_receive(:subscribe).with("worker-1234").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      @p.should_receive(:shutdown)
      @p.run
    end
  end

  describe "process job" do
    it "should call create for and send a finished message" do
      Processor.should_receive(:create_for).with("geo", "field", "value", "desc", "ncbo_id", "current_ncbo_id", "stopwords").and_return(true)
      Messaging.should_receive(:publish).with("scheduler-queue", "{\"command\":\"finished\",\"job_id\":1,\"worker_key\":null}").and_return(true)
      hash = {'geo_accession' => "geo", 'field' => "field", 'value' => "value", 'description' => "desc", 'ncbo_id' => "ncbo_id", 'job_id' => 1, 'stopwords' => 'stopwords', 'current_ncbo_id' => 'current_ncbo_id'}
      p = Processor.new
      p.process_job(hash).should be_true
    end
  end

  describe "shutdown" do
    it "should send a message and quit" do
      Messaging.should_receive(:publish).with("scheduler-queue", "{\"command\":\"shutdown\",\"worker_key\":null}").and_return(true)
      AMQP.should_receive(:stop).and_return(true)
      p = Processor.new
      p.should_receive(:exit).and_return(true)
      p.shutdown.should be_true
    end
  end

  describe "create for" do
    it "should get the information from NCBO and process it" do
      NCBOService.should_receive(:result_hash).with("field_value", "current_ncbo_id", "stopwords").and_return("hash")
      Processor.should_receive(:process_ncbo_results).with("hash", "GSM1234", "field_name", "description", "ncbo_id").and_return(true)
      Processor.create_for("GSM1234", "field_name", "field_value", "description", "ncbo_id", "current_ncbo_id", "stopwords").should be_true
    end
  end

  describe "process ncbo results" do
    it "should process the hash" do
      Processor.should_receive(:process_mgrep).with({:mg => "value"}, "GPL1234", "summary", "desc", "ncbo_id").and_return(true)
      Processor.should_receive(:process_closure).with({:cl => "value"}, "GPL1234", "summary", "ncbo_id").and_return(true)
      Processor.process_ncbo_results({"MGREP" => {:mg => "value"}, "ISA_CLOSURE" => {:cl => "value"}}, "GPL1234", "summary", "desc", "ncbo_id")
    end
  end

  describe "process closure" do
    it "should create annotation closures" do
      hash = {
        "MSH|C0003062"=> [
          {:name => "MeSH Descriptors", :id => "MSH|C1256739"}
          ],
        "MSH|C0034721"=> [
          {:name => "Animals", :id => "MSH|C0003062"},
          ]
      }
      Processor.should_receive(:save_term).with('term_id' => "ncbo_id|C1256739", 'ncbo_id' => "ncbo_id", 'term_name' => "MeSH Descriptors").and_return(true)
      Processor.should_receive(:save_closure).with('geo_accession' => "GSM1234", 'field_name' => 'fname', 'term_id' => "ncbo_id|C0003062", 'closure_term' => "ncbo_id|C1256739").and_return(true)

      Processor.should_receive(:save_term).with('term_id' => "ncbo_id|C0003062", 'ncbo_id' => "ncbo_id", 'term_name' => "Animals").and_return(true)
      Processor.should_receive(:save_closure).with('geo_accession' => "GSM1234", 'field_name' => 'fname', 'term_id' => "ncbo_id|C0034721", 'closure_term' => "ncbo_id|C0003062").and_return(true)

      Processor.process_closure(hash, "GSM1234", "fname", "ncbo_id")
    end
  end

  describe "process mgrep" do
    it "should create annotations" do
      hash = {
        "MSH|C0003062"=>{:name=>"Animals", :from => "19", :to => "25"}
      }
      Processor.should_receive(:save_term).with('term_id' => "ncbo_id|C0003062", 'ncbo_id' => "ncbo_id", 'term_name' => "Animals").and_return(true)
      Processor.should_receive(:save_annotation).with('geo_accession' => "GSM1234", 'field_name' => "fname", 'ncbo_id' => "ncbo_id", 'ontology_term_id' => "ncbo_id|C0003062", 'text_start' => "19", 'text_end' => "25", 'description' => "desc")
      Processor.process_mgrep(hash, "GSM1234", "fname", "desc", "ncbo_id")
    end

    it "should create an empty annotation if we didn't get back any results" do
      hash = {}
      Processor.should_receive(:save_annotation).with('geo_accession' => "GSM1234", 'field_name' => "fname", 'ncbo_id' => "none", 'ontology_term_id' => "none", 'text_start' => "0", 'text_end' => "0", 'description' => "")
      Processor.process_mgrep(hash, "GSM1234", "fname", "desc", "ncbo_id")
    end
  end

  describe "save term" do
    it "should send the term message" do
      Processor.should_receive(:databaser_message).with("{\"command\":\"saveterm\",\"key\":\"value\"}").and_return(true)
      Processor.save_term({'key' => 'value'})
    end
  end

  describe "save annotation" do
    it "should send the annotation message" do
      Processor.should_receive(:databaser_message).with("{\"command\":\"saveannotation\",\"key\":\"value\"}").and_return(true)
      Processor.save_annotation({'key' => 'value'})
    end
  end

  describe "save closure" do
    it "should send the closure message" do
      Processor.should_receive(:databaser_message).with("{\"command\":\"saveclosure\",\"key\":\"value\"}").and_return(true)
      Processor.save_closure({'key' => 'value'})
    end
  end

  describe "databaser_message" do
    it "should send the databaser_message" do
      Messaging.should_receive(:publish).with("databaser-queue", "message").and_return(true)
      Processor.databaser_message("message")
    end
  end

  describe "new" do
    it "should use the default server" do
      Messaging.should_receive(:server).with('localhost').and_return(true)
      p = Processor.new
    end

    it "should use the specified server" do
      Messaging.should_receive(:server).with('server').and_return(true)
      p = Processor.new('server')
    end
  end

  
end
