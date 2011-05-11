require 'spec_helper'


class FakeClass
  include Utilities
  extend Utilities::ClassMethods
end

describe Utilities do

  describe "load item" do
    it "should return a sample" do
      sample = mock(Sample)
      Sample.should_receive(:first).with(:conditions => {:geo_accession => "GSM1234"}, :select=>"*").and_return(sample)
      FakeClass.load_item("GSM1234").should == sample
    end

    it "should return a series" do
      series = mock(SeriesItem)
      SeriesItem.should_receive(:first).with(:conditions => {:geo_accession => "GSE1234"}, :select=>"*").and_return(series)
      FakeClass.load_item("GSE1234").should == series
    end

    it "should return a dataset" do
      dataset = mock(Dataset)
      Dataset.should_receive(:first).with(:conditions => {:geo_accession => "GDS1234"}, :select=>"*").and_return(dataset)
      FakeClass.load_item("GDS1234").should == dataset
    end

    it "should return a platform" do
      platform = mock(Gminer::Platform)
      Gminer::Platform.should_receive(:first).with(:conditions => {:geo_accession => "GPL1234"}, :select=>"*").and_return(platform)
      FakeClass.load_item("GPL1234").should == platform
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

  describe "annotations for" do
    it "should call find in the Annotation model" do
      fake = FakeClass.new
      fake.should_receive(:geo_accession).and_return("geo")
      Annotation.should_receive(:find_by_sql).with("SELECT a.* FROM annotations AS a, ontologies AS o, ontology_terms AS t WHERE a.geo_accession = 'geo' AND a.field_name = 'title' AND a.ontology_term_id != -1 AND a.ontology_term_id = t.id AND t.ncbo_id = o.ncbo_id ORDER BY o.name, t.name").and_return(["annotation"])
      fake.annotations_for("title").should == ["annotation"]
    end
  end

  describe "keys" do
    describe "disable" do
      it "should disable keys for the selected model" do
        Annotation.disable_keys
      end
    end

    describe "enable" do
      it "should enable keys for the selected model" do
        Annotation.enable_keys
      end
    end
  end

  describe "prev next" do
    it "should return the previous and next items in the array" do
      Constants::GEO_ACCESSION_IDS['Sample'] = ["GSM1", "GSM2", "GSM3"]
      sample = Factory.build(:sample, :geo_accession => "GSM2")
      sample.prev_next.should == ["GSM1", "GSM3"]
    end
  end

  describe "count_by_ontology_array" do
    it "should return a count of annotations for each ontology in that item" do
      o = Factory.build(:ontology)
      Ontology.should_receive(:all).and_return([o])
      a = Factory.build(:annotation)
      sample = Factory.build(:sample, :geo_accession => "GSM2")
      sample.should_receive(:annotations).and_return([a])
      sample.count_by_ontology_array.should == [{:name=>"mouse anatomy", :amount=>1}, {:name=>"Pathway Ontology", :amount=>0}, {:name=>"Basic Vertebrate Anatomy", :amount=>0}, {:name=>"Mammalian Phenotype", :amount=>0}, {:name=>"Mouse adult gross anatomy", :amount=>0}, {:name=>"Cell type", :amount=>0}, {:name=>"Rat Strain Ontology", :amount=>0}, {:name=>"Gene Ontology", :amount=>0}, {:name=>"Medical Subject Headings", :amount=>0}, {:name=>"NCI Thesaurus", :amount=>0}, {:name=>"All ontology", :amount=>0}]
    end
  end

  describe "descriptive_text" do
    before(:each) do
      @fake = FakeClass.new
      @fake.should_receive(:title).and_return("title")
    end

    it "should return a sample" do
      series = Factory.build(:series_item, :title => "seriestitle")
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
