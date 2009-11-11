require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Job do

  describe "get_statistics" do
    it "should return a hash" do
      Job.get_statistics.should be_a_kind_of(Hash)
    end

    ["Platform", "Dataset", "Sample", "Series"].each do |geo|
      it "should return a hash with #{geo} as a key" do
        hash = Job.get_statistics
        hash.should have_key(geo)
      end
    end

    HASH = {
      "Platform" => {:count => 4, :fields => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}},
      "Dataset" => {:count => 4, :fields => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}},
      "Sample" => {:count => 4, :fields => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}},
      "Series" => {:count => 4, :fields => {'desc' => {:count => 1, :ontologies => {'rat' => {:count => 1}}}}}
    }

    it "should query database for geo types" do
      pending
      Job.should_receive(:find)
      Job.get_statistics
    end

  end


  describe "page" do
    it "should call paginate" do
      Job.should_receive(:paginate).with({:order => "jobs.finished_at", :conditions=>"conditions", :page=>2, :joins => [:ontology], :per_page=>20}).and_return(true)
      Job.page("conditions", 2, 20)
    end
  end

  describe "has_annotation?" do
    it "should return an annotation if it exists" do
      job = Job.spawn
      a = Annotation.spawn
      Annotation.should_receive(:first).with(:conditions => {:geo_accession => "GPL1355", :field => "description"}).and_return(a)
      job.has_annotation?.should == a
    end

    it "should return nil if it doesn't exist" do
      job = Job.spawn
      Annotation.should_receive(:first).with(:conditions => {:geo_accession => "GPL1355", :field => "description"}).and_return(nil)
      job.has_annotation?.should == nil
    end
  end

  describe "create_for" do
    it "should create jobs for the geo accession and it's fields if it doesn't exist" do
      Job.should_receive(:first).with(:conditions => {:geo_accession => "GPL12", :field => "description", :ontology_id => "2"}).and_return(nil)
      Job.should_receive(:create).with(:geo_accession => "GPL12", :field => "description", :ontology_id => "2").and_return(true)
      Job.create_for("GPL12", "2", "description")
    end

    it "should create jobs for the geo accession and it's fields if it doesn't exist" do
      job = Job.spawn
      Job.should_receive(:first).with(:conditions => {:geo_accession => "GPL12", :field => "description", :ontology_id => "2"}).and_return(job)
      Job.create_for("GPL12", "2", "description")
    end
  end

end
