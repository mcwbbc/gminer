require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Utilities do

  class FakeClass
    include Utilities
    extend Utilities::ClassMethods
  end

  describe "join item" do
    before(:each) do
      @f = FakeClass.new
    end
    it "should return a joined string for an array" do
      @f.join_item(["a", "b"]).should == "a b"
    end

    it "should return the item for non array" do
      @f.join_item("a").should == "a"
    end
  end

  describe "load item" do
    it "should return a sample" do
      sample = mock(Sample)
      Sample.should_receive(:first).with(:conditions => {:geo_accession => "GSM1234"}).and_return(sample)
      FakeClass.load_item("GSM1234").should == sample
    end

    it "should return a series" do
      series = mock(SeriesItem)
      SeriesItem.should_receive(:first).with(:conditions => {:geo_accession => "GSE1234"}).and_return(series)
      FakeClass.load_item("GSE1234").should == series
    end

    it "should return a dataset" do
      dataset = mock(Dataset)
      Dataset.should_receive(:first).with(:conditions => {:geo_accession => "GDS1234"}).and_return(dataset)
      FakeClass.load_item("GDS1234").should == dataset
    end

    it "should return a platform" do
      platform = mock(Platform)
      Platform.should_receive(:first).with(:conditions => {:geo_accession => "GPL1234"}).and_return(platform)
      FakeClass.load_item("GPL1234").should == platform
    end
  end

  describe "persist (class)" do
    it "should check for an existing platform, and create a new one if it doesn't exist" do
      FakeClass.should_receive(:first).with(:conditions => {:geo_accession => "GPL1234"}).and_return(nil)
      p = mock(Platform)
      FakeClass.should_receive(:new).with(:geo_accession => "GPL1234").and_return(p)
      p.should_receive(:new_record?).and_return(true)
      p.should_receive(:persist).and_return(true)
      FakeClass.persist("GPL1234")
    end

    it "should check for an existing platform, and persist if forced" do
      p = mock(Platform)
      FakeClass.should_receive(:first).with(:conditions => {:geo_accession => "GPL1234"}).and_return(p)
      p.should_receive(:new_record?).and_return(false)
      p.should_receive(:persist).and_return(true)
      FakeClass.persist("GPL1234", true)
    end

    it "should check for an existing platform, and do nothing if not forced" do
      p = mock(Platform)
      FakeClass.should_receive(:first).with(:conditions => {:geo_accession => "GPL1234"}).and_return(p)
      p.should_receive(:new_record?).and_return(false)
      p.should_not_receive(:persist)
      FakeClass.persist("GPL1234")
    end
  end

  describe "strip newlines" do
    it "should remove the newlines from the text" do
      FakeClass.strip_newlines("hello there\r\nworld").should == "hello there world"
    end

    it "should remove multi newlines from the text" do
      FakeClass.strip_newlines("hello there\n\n\nworld").should == "hello there world"
    end

    it "should remove multi cr\newlines from the text" do
      FakeClass.strip_newlines("hello there\r\n\r\n\r\nworld").should == "hello there world"
    end

    it "should remove carriage returns from the text" do
      FakeClass.strip_newlines("hello there\rworld").should == "hello there world"
    end
  end

  describe "file hash" do
    before(:each) do
      @fake = FakeClass.new
      @matchers = [ {:name => "title", :regex => /^!Sample_title = (.+)$/},
                   {:name => "sample_type", :regex => /^!Sample_type = (.+?)$/}
                 ]
    end

    it "should generate a hash based on the supplied matchers for the file" do
      @lines = ["!Sample_title = rat title", "!Sample_type = rat type"]
      File.should_receive(:open).with("filename", "r").and_return(@lines)
      @fake.file_hash(@matchers, "filename").should == {"title" => ["rat title"], "sample_type" => ["rat type"]}
    end

    it "should generate an empty arrayed hash for non matches" do
      @lines = ["rat title", "rat type"]
      File.should_receive(:open).with("filename", "r").and_return(@lines)
      @fake.file_hash(@matchers, "filename").should == {"title" => [], "sample_type" => []}
    end

    it "should generate an hash with multiple array entries" do
      @lines = ["!Sample_title = rat title", "!Sample_type = rat type", "!Sample_type = mouse type"]
      File.should_receive(:open).with("filename", "r").and_return(@lines)
      @fake.file_hash(@matchers, "filename").should == {"title" => ["rat title"], "sample_type" => ["rat type", "mouse type"]}
    end
  end

  describe "write file" do
    it "should write the text to the supplied filename" do
      fake = FakeClass.new
      file = mock("file")
      file.should_receive(:write).with("text").and_return(true)
      File.should_receive(:open).with("filename", "w").and_yield(file)
      fake.write_file("filename", "text").should == true
    end
  end

  describe "gunzip" do
    it "should gunzip the supplied file" do
      allow_message_expectations_on_nil
      fake = FakeClass.new
      fake.should_receive(:system).with("gunzip --force hello.gz").and_return(true)
      $?.should_receive(:exitstatus).and_return(0)
      fake.gunzip("hello.gz").should == true
    end
  end

  describe "annotations for" do
    it "should call find in the Annotation model" do
      fake = FakeClass.new
      fake.should_receive(:geo_accession).and_return("geo")
      Annotation.should_receive(:find_by_sql).with("SELECT a.* FROM annotations AS a, ontologies AS o, ontology_terms AS t WHERE a.geo_accession = 'geo' AND a.field = 'title' AND a.ontology_term_id != -1 AND a.ontology_term_id = t.id AND t.ncbo_id = o.ncbo_id ORDER BY o.name, t.name").and_return(["annotation"])
      fake.annotations_for("title").should == ["annotation"]
    end
  end

  describe "remove item" do
    before(:each) do
      @fake = FakeClass.new
    end

    it "should remove the pack directory" do
      File.should_receive(:exists?).and_return(true)
      FileUtils.should_receive(:rm_r).and_return(true)
      @fake.remove_item("dir")
    end

    it "should not remove the pack directory" do
      File.should_receive(:exists?).and_return(false)
      FileUtils.should_not_receive(:rm_r).and_return(true)
      @fake.remove_item("dir")
    end
  end

  describe "make directory" do
    before(:each) do
      @fake = FakeClass.new
    end

    describe "with existing" do
      it "should not create it" do
        File.should_receive(:exists?).with("cheese").and_return(true)
        Dir.should_not_receive(:mkdir)
        @fake.make_directory("cheese")
      end
    end
    describe "without existing" do
      it "should create it" do
        File.should_receive(:exists?).with("cheese").and_return(false)
        Dir.should_receive(:mkdir).with("cheese").and_return(true)
        @fake.make_directory("cheese")
      end
    end
  end

  describe "keys" do
    before(:each) do
      @connection = mock("connection")
      @connection.stub!(:open_transactions).and_return(true)
      @connection.stub!(:rollback_db_transaction).and_return(true)
      @connection.stub!(:decrement_open_transactions).and_return(true)
      ActiveRecord::Base.stub!(:connection).and_return(@connection)
    end

    describe "disable" do
      it "should disable keys for the selected model" do
        @connection.should_receive(:execute).with("ALTER TABLE fake_classes DISABLE KEYS;").and_return(true)
        FakeClass.disable_keys
      end
    end

    describe "enable" do
      it "should enable keys for the selected model" do
        @connection.should_receive(:execute).with("ALTER TABLE fake_classes ENABLE KEYS;").and_return(true)
        FakeClass.enable_keys
      end
    end
  end

  describe "prev next" do
    it "should return the previous and next items in the array" do
      sample = Sample.spawn(:geo_accession => "GSM2")
      s1 = Sample.spawn(:geo_accession => "GSM1")
      s2 = Sample.spawn(:geo_accession => "GSM2")
      s3 = Sample.spawn(:geo_accession => "GSM3")
      Sample.should_receive(:all).with(:order => [:geo_accession]).and_return([s1,s2,s3])
      sample.prev_next.should == ["GSM1", "GSM3"]
    end
  end

  describe "count_by_ontology_array" do
    it "should return a count of annotations for each ontology in that item" do
      o = Ontology.spawn
      Ontology.should_receive(:all).and_return([o])
      a = Annotation.spawn
      sample = Sample.spawn(:geo_accession => "GSM2")
      sample.should_receive(:annotations).and_return([a])
      sample.count_by_ontology_array.should == [{:amount=>1, :name=>"mouse anatomy"}, {:amount=>0, :name=>"NCI Thesaurus"}, {:amount=>0, :name=>"Basic Vertebrate Anatomy"}, {:amount=>0, :name=>"Pathway Ontology"}, {:amount=>0, :name=>"Medical Subject Headings, 2009_2008_08_06"}, {:amount=>0, :name=>"Gene Ontology"}, {:amount=>0, :name=>"Mouse adult gross anatomy"}, {:amount=>0, :name=>"Rat Strain Ontology"}, {:amount=>0, :name=>"Mammalian Phenotype"}]
    end
  end

  describe "descriptive_text" do
    before(:each) do
      @fake = FakeClass.new
      @fake.should_receive(:title).and_return("title")
    end

    it "should return a sample" do
      series = mock(SeriesItem, :title => "seriestitle")
      @fake.should_receive(:series_item).and_return(series)
      @fake.should_receive(:geo_accession).and_return("GSM1234")
      @fake.descriptive_text.should == "seriestitle - title"
    end

    it "should return a series" do
      @fake.should_receive(:geo_accession).and_return("GSE1234")
      @fake.descriptive_text.should == "title"
    end

    it "should return a platform" do
      @fake.should_receive(:geo_accession).and_return("GPL1234")
      @fake.descriptive_text.should == "title"
    end

    it "should return a dataset" do
      @fake.should_receive(:geo_accession).and_return("GDS1234")
      @fake.descriptive_text.should == "title"
    end
  end

end
