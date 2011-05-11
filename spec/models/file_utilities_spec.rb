require 'spec_helper'

class FakeClass
  include FileUtilities
  extend FileUtilities::ClassMethods
end

describe FileUtilities do

  describe "file hash" do
    before(:each) do
      @fake = FakeClass.new
      @matchers = [ {:name => "title", :regex => /^!Sample_title = (.+)$/},
                   {:name => "sample_type", :regex => /^!Sample_type = (.+?)$/}
                 ]
    end

    it "should generate a hash based on the supplied matchers for the file" do
      @lines = ["!Sample_title = rat title", "!Sample_type = rat type"]
      File.should_receive(:open).with("filename", "rb", {:encoding=>"ISO-8859-1"}).and_return(@lines)
      @fake.file_hash(@matchers, "filename").should == {"title" => ["rat title"], "sample_type" => ["rat type"]}
    end

    it "should generate an empty arrayed hash for non matches" do
      @lines = ["rat title", "rat type"]
      File.should_receive(:open).with("filename", "rb", {:encoding=>"ISO-8859-1"}).and_return(@lines)
      @fake.file_hash(@matchers, "filename").should == {"title" => [], "sample_type" => []}
    end

    it "should generate an hash with multiple array entries" do
      @lines = ["!Sample_title = rat title", "!Sample_type = rat type", "!Sample_type = mouse type"]
      File.should_receive(:open).with("filename", "rb", {:encoding=>"ISO-8859-1"}).and_return(@lines)
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
      fake = FakeClass.new
      fake.should_receive(:system).with("gunzip --force hello.gz").and_return(true)
      $?.should_receive(:exitstatus).and_return(0)
      fake.gunzip("hello.gz").should == true
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

  describe "persist (class)" do
    it "should check for an existing platform, and create a new one if it doesn't exist" do
      FakeClass.should_receive(:first).with(:conditions => {:geo_accession => "GPL1234"}).and_return(nil)
      p = Factory.build(:platform)
      FakeClass.should_receive(:new).with(:geo_accession => "GPL1234").and_return(p)
      p.should_receive(:new_record?).and_return(true)
      p.should_receive(:persist).and_return(true)
      FakeClass.persist("GPL1234")
    end

    it "should check for an existing platform, and persist if forced" do
      p = Factory.build(:platform)
      FakeClass.should_receive(:first).with(:conditions => {:geo_accession => "GPL1234"}).and_return(p)
      p.should_receive(:new_record?).and_return(false)
      p.should_receive(:persist).and_return(true)
      FakeClass.persist("GPL1234", true)
    end

    it "should check for an existing platform, and do nothing if not forced" do
      p = Factory.build(:platform)
      FakeClass.should_receive(:first).with(:conditions => {:geo_accession => "GPL1234"}).and_return(p)
      p.should_receive(:new_record?).and_return(false)
      p.should_not_receive(:persist)
      FakeClass.persist("GPL1234")
    end
  end

end
