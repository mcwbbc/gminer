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
      Sample.should_receive(:get).with("GSM1234").and_return(sample)
      FakeClass.load_item("GSM1234").should == sample
    end

    it "should return a series" do
      series = mock(SeriesItem)
      SeriesItem.should_receive(:get).with("GSE1234").and_return(series)
      FakeClass.load_item("GSE1234").should == series
    end

    it "should return a dataset" do
      dataset = mock(Dataset)
      Dataset.should_receive(:get).with("GDS1234").and_return(dataset)
      FakeClass.load_item("GDS1234").should == dataset
    end

    it "should return a platform" do
      platform = mock(Platform)
      Platform.should_receive(:get).with("GPL1234").and_return(platform)
      FakeClass.load_item("GPL1234").should == platform
    end
  end

  describe "persist (class)" do
    it "should check for an existing platform, and create a new one if it doesn't exist" do
      FakeClass.should_receive(:first).with(:geo_accession => "GPL1234").and_return(nil)
      p = mock(Platform)
      FakeClass.should_receive(:new).with(:geo_accession => "GPL1234").and_return(p)
      p.should_receive(:persist).and_return(true)
      FakeClass.persist("GPL1234")
    end

    it "should check for an existing platform, and do nothing if it existed" do
      p = mock(Platform)
      FakeClass.should_receive(:first).with(:geo_accession => "GPL1234").and_return(p)
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

  describe "remove stopwords" do
    it "should remove words inside the stopword array" do
      FakeClass.remove_stopwords("a an the al. with").should == " "
    end

    it "should remove words inside the stopword array cased" do
      FakeClass.remove_stopwords("A An THE").should == " "
    end

    it "should not remove words in the stopword array that are there as parts of other words" do
      FakeClass.remove_stopwords("anteater theory").should == "anteater theory"
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

  describe "create annotation" do
    it "should call create for in the Annotation model" do
      fake = FakeClass.new
      fake.should_receive(:geo_accession).and_return("geo")
      fake.should_receive(:fields).and_return("fields")
      fake.should_receive(:descriptive_text).and_return("text")
      Annotation.should_receive(:create_for).with("geo", "fields", "text").and_return(["annotation"])
      fake.create_annotations.should == ["annotation"]
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

  describe "annotation" do
    it "should call find in the Annotation model" do
      fake = FakeClass.new
      fake.should_receive(:geo_accession).and_return("geo")
      Annotation.should_receive(:find_by_sql).with("SELECT a.* FROM annotations AS a, ontology_terms AS t WHERE a.geo_accession = 'geo' AND a.ontology_term_id != 'none' AND a.ontology_term_id = t.term_id ORDER BY t.term_id").and_return(["annotation"])

      fake.annotations.should == ["annotation"]
    end
  end

  describe "annotations for" do
    it "should call find in the Annotation model" do
      fake = FakeClass.new
      fake.should_receive(:geo_accession).and_return("geo")
      Annotation.should_receive(:find_by_sql).with("SELECT a.* FROM annotations AS a, ontologies AS o, ontology_terms AS t WHERE a.geo_accession = 'geo' AND a.field = 'title' AND a.ontology_term_id != 'none' AND a.ontology_term_id = t.term_id AND t.ncbo_id = o.ncbo_id ORDER BY o.name, t.name").and_return(["annotation"])

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

end
