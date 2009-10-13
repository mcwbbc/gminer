require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Job do

  describe "create_for" do
    before(:each) do
      @platform = Platform.spawn(:geo_accession => "GPL12")
      Job.should_receive(:load_item).with("GPL12").and_return(@platform)
    end

    it "should create jobs for the geo accession and it's fields if it doesn't exist" do
      Job.should_receive(:first).with(:conditions => {:geo_accession => "GPL12", :field => "description", :ontology_id => "2"}).and_return(nil)
      Job.should_receive(:create).with(:geo_accession => "GPL12", :field => "description", :ontology_id => "2").and_return(true)
      Job.create_for("GPL12", "2", "description")
    end

    it "should create jobs for the geo accession and it's fields if it doesn't exist" do
      job = Job.generate
      Job.should_receive(:first).with(:conditions => {:geo_accession => "GPL12", :field => "description", :ontology_id => "2"}).and_return(job)
      Job.create_for("GPL12", "2", "description")
    end
  end

  describe "available" do
    before(:each) do
      @one = Job.generate
    end

    it "should return the first available job" do
      # (worker_key IS NULL AND (finished_at IS NULL OR finished_at < 2.weeks.ago)) OR (worker_key IS NOT NULL AND started_at < 5.minutes.ago)
      right_now = Time.now
      Job.should_receive(:first).with(:conditions => ["(worker_key IS NULL AND (finished_at IS NULL OR finished_at < ?)) OR (worker_key IS NOT NULL AND started_at < ?)", right_now, right_now]).and_return(@one)
      Job.available(:expired_at => right_now, :crashed_at => right_now).should == @one
    end

    it "should return the count of available jobs" do
      right_now = Time.now
      Job.should_receive(:count).with(:conditions => ["(worker_key IS NULL AND (finished_at IS NULL OR finished_at < ?)) OR (worker_key IS NOT NULL AND started_at < ?)", right_now, right_now]).and_return(10)
      Job.available(:expired_at => right_now, :crashed_at => right_now, :count => true).should == 10
    end
  end
  
end
