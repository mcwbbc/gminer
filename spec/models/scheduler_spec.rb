require File.dirname(__FILE__) + '/../spec_helper'

describe Scheduler do

  describe "create_worker" do
    it "should create a worker and send a prepare message" do
      Worker.should_receive(:create).with({:worker_key=>"1234", :working=>false}).and_return("worker")
      Messaging.should_receive(:publish).with("worker-1234", "{\"command\":\"prepare\"}").and_return(true)
      s = Scheduler.new
      s.create_worker("1234").should be_true
    end
  end

  describe "send_job" do
    it "should set the worker working and send a job message" do
      worker = Worker.generate
      worker.should_receive(:update_attributes).with(:working => true).and_return(true)
      Worker.should_receive(:first).with(:conditions => {:worker_key=>"1234"}).and_return(worker)
      Messaging.should_receive(:publish).with("worker-1234", "{\"command\":\"job\",\"key\":\"value\"}").and_return(true)
      s = Scheduler.new
      s.send_job("1234", {'key' => 'value'}).should be_true
    end
  end

  describe "watch_queue" do
    before(:each) do
      @s = Scheduler.new
      @t = mock("thread")
      Messaging.should_receive(:thread).and_return(@t)
      @t.should_receive(:join).and_return(true)
      @message = {'worker_key' => '1234', 'job_id' => '12'}
      @s.should_receive(:launch_timer).and_return(true)
    end

    it "should create the worker" do
      @message.merge!({'command' => 'alive'})
      Messaging.should_receive(:subscribe).with("scheduler-queue").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      @s.should_receive(:create_worker).with("1234").and_return(true)
      @s.watch_queue
    end

    it "should start the job" do
      @message.merge!({'command' => 'ready'})
      Messaging.should_receive(:subscribe).with("scheduler-queue").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      @s.should_receive(:start_job).with("1234").and_return(true)
      @s.watch_queue
    end

    it "should update the job" do
      @message.merge!({'command' => 'working'})
      Messaging.should_receive(:subscribe).with("scheduler-queue").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      @s.should_receive(:started_job).with("1234", "12").and_return(true)
      @s.watch_queue
    end

    it "should finish the job" do
      @message.merge!({'command' => 'finished'})
      Messaging.should_receive(:subscribe).with("scheduler-queue").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      @s.should_receive(:finished_job).with("1234", "12").and_return(true)
      @s.watch_queue
    end

    it "should launch a worker" do
      @message.merge!({'command' => 'launch'})
      Messaging.should_receive(:subscribe).with("scheduler-queue").and_yield(@message)
      JSON.should_receive(:parse).with(@message).and_return(@message)
      @s.should_receive(:launch_worker).and_return(true)
      @s.watch_queue
    end
  end

  describe "started_job" do
    it "should update the job attributes" do
      job = Job.generate
      Job.should_receive(:first).with(:conditions => {:id=>"12"}).and_return(job)
      job.should_receive(:update_attributes).with(hash_including(:worker_key => "1234")).and_return(true)
      s = Scheduler.new
      s.started_job("1234", "12")
    end
  end

  describe "finished_job" do
    it "should update the job attributes" do
      job = Job.generate
      Job.should_receive(:first).with(:conditions => {:id=>"12"}).and_return(job)
      job.should_receive(:update_attributes).with(hash_including(:worker_key => nil)).and_return(true)
      worker = Worker.generate
      Worker.should_receive(:first).with(:conditions => {:worker_key => "1234"}).and_return(worker)
      worker.should_receive(:update_attributes).with(:working => false).and_return(true)
      Messaging.should_receive(:publish).with("worker-1234", "{\"command\":\"prepare\"}").and_return(true)
      s = Scheduler.new
      s.finished_job("1234", "12")
    end
  end

  describe "run" do
    before(:each) do
      @s = Scheduler.new
      @s.should_receive(:launch_databaser)
      @s.should_receive(:watch_queue)
    end

    it "should run the steps without launching a worker" do
      Job.should_receive(:available).with(:count => true).and_return(1)
      Messaging.should_not_receive(:publish)
      @s.run
    end

  end

  describe "launch workers" do
    it "should launch workers" do
      @s = Scheduler.new
      Rails.stub!(:root).and_return("root")
      Process.should_receive(:fork).twice.and_yield
      Process.should_receive(:detach).and_return(true)
      @s.should_receive(:exit).and_return(true)
      @s.should_receive(:exec).with("cd root/lib/launchers && ruby root/lib/launchers/launch_processor.rb").and_return(true)
      @s.launch_worker
    end
  end

  describe "launch databaser" do
    it "should launch databaser" do
      @s = Scheduler.new
      Rails.stub!(:root).and_return("root")
      Process.should_receive(:fork).twice.and_yield
      Process.should_receive(:detach).and_return(true)
      @s.should_receive(:exit).and_return(true)
      @s.should_receive(:exec).with("rake RAILS_ENV=test distribute:databaser").and_return(true)
      @s.launch_databaser
    end
  end

  describe "launch timer" do
    before(:each) do
      @s = Scheduler.new
      @t = mock("timer")
      EM::PeriodicTimer.should_receive(:new).with(5).and_yield(@t).and_return(@t)
    end

    it "should set a time to launch more instances every 5 seconds" do
      @s.should_receive(:launch_more).and_return(true)
      @s.launch_timer
    end

#    it "should set a time to launch more instances every 5 seconds and stop when full" do
#      @s.should_receive(:launch_more).and_return(false)
#      @t.should_receive(:cancel).and_return(true)
#      @s.launch_timer
#    end
  end

  describe "launch more" do
    before(:each) do
      @s = Scheduler.new
      @s.stub!(:worker_max).and_return(5)
    end

    it "should launch more if we have jobs and fewer workers" do
      Job.should_receive(:available).with(:count => true).and_return(2)
      Worker.should_receive(:count).and_return(4)
      Messaging.should_receive(:publish).with("scheduler-queue", "{\"command\":\"launch\"}").and_return(true)
      @s.launch_more.should == true
    end

    it "should not launch more if we don't have jobs" do
      Job.should_receive(:available).with(:count => true).and_return(1)
      Worker.should_receive(:count).and_return(1)
      Messaging.should_not_receive(:publish)
      @s.launch_more.should == false
    end

    it "should not launch more if we have enough workers" do
      Worker.should_receive(:count).and_return(5)
      Messaging.should_not_receive(:publish)
      @s.launch_more.should == false
    end
  end

  describe "start job" do
    before(:each) do
      @worker = Worker.generate
      Worker.should_receive(:first).with(:conditions => {:worker_key => "1234"}).and_return(@worker)
      @worker.should_receive(:update_attributes).with(:ready => true).and_return(true)
      @s = Scheduler.new
    end

    describe "with an available job" do
      before(:each) do
        @ontology = Ontology.spawn
        @job = Job.spawn(:ontology => @ontology)
        Job.should_receive(:available).and_return(@job)
      end

      describe "with an existing annotation" do
        it "should send the finished job" do
          Annotation.should_receive(:first).with(:conditions => {:field => "description", :geo_accession=>"GPL1355"}).and_return("annotation")
          @s.should_receive(:finished_job).with("1234", @job.id).and_return(true)
          @s.start_job("1234")
        end
      end
      
      describe "without an existing annotation" do
        before(:each) do
          @job.should_receive(:update_attributes).with(hash_including(:worker_key=>"1234")).and_return(true)
          @platform = Platform.spawn
          @platform.should_receive(:description).and_return("platform")
          Job.should_receive(:load_item).with("GPL1355").and_return(@platform)
          @ontology = Ontology.spawn
          @job.stub!(:ontology).and_return(@ontology)
        end

        describe "with empty stopwords" do
          it "should process the job" do
            @ontology.should_receive(:stopwords).and_return("")
            @s.should_receive(:send_job).with("1234", {'stopwords' => Constants::STOPWORDS, "ncbo_id" => "1000", "current_ncbo_id" => "13578", "geo_accession" => "GPL1355", "value" => "platform", "field" => "description", "description" => "Platform Title", "job_id" => @job.id}).and_return(true)
            @s.start_job("1234")
          end
        end

        describe "with custom stopwords" do
          it "should process the job" do
            @ontology.should_receive(:stopwords).twice.and_return("stopwords")
            @s.should_receive(:send_job).with("1234", {'stopwords' => 'stopwords', "ncbo_id" => "1000", "current_ncbo_id" => "13578", "geo_accession" => "GPL1355", "value" => "platform", "field" => "description", "description" => "Platform Title", "job_id" => @job.id}).and_return(true)
            @s.start_job("1234")
          end
        end
      end
    end

    describe "without an available job" do
      it "should call no jobs" do
        Job.should_receive(:available).and_return(nil)
        @s.should_receive(:no_jobs).with("1234").and_return(true)
        @s.start_job("1234")
      end
    end
  end

  describe "no_jobs" do
    before(:each) do
      @s = Scheduler.new
    end

    describe "with excess workers" do
      it "should delete the worker" do
        Worker.should_receive(:count).with(:conditions => {:working => false}).and_return(2)
        Messaging.should_receive(:publish).with("worker-1234", "{\"command\":\"shutdown\"}").and_return(true)
        worker = Worker.generate
        Worker.should_receive(:first).with(:conditions => {:worker_key=> "1234"}).and_return(worker)
        worker.should_receive(:destroy).and_return(true)
        @s.no_jobs("1234")
      end
    end

    describe "without excess workers" do
      it "should enter a wait loop" do
        Worker.should_receive(:count).with(:conditions => {:working => false}).and_return(1)
        EM.should_receive(:add_timer).with(10).and_yield
        Messaging.should_receive(:publish).with("worker-1234", "{\"command\":\"prepare\"}").and_return(true)
        @s.no_jobs("1234")
      end
    end
  end

  describe "clean worker queues" do
    it "should return the workers" do
      worker = Worker.generate
      Worker.should_receive(:all).and_return([worker])
      @s = Scheduler.new
      @s.clean_worker_queues.should == [worker]
    end
  end

end
