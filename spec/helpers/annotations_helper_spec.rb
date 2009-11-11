require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AnnotationsHelper do

  #Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(AnnotationsHelper)
  end

  describe "ontology_search_dropdown" do
    it "should return a select tag" do
      ontology = Ontology.spawn
      Ontology.should_receive(:which_have_annotations).and_return([ontology])
      helper.ontology_search_dropdown("").should == "<select id=\"ddown\" name=\"ddown\"><option value=\"1000\">mouse anatomy</option></select>"
    end
  end

  describe "annotation_status_dropdown" do
    it "should return a select tag" do
      helper.annotation_status_dropdown("").should == "<select id=\"status\" name=\"status\"><option value=\"Unaudited\">Unaudited</option>\n<option value=\"Valid\">Valid</option>\n<option value=\"Invalid\">Invalid</option>\n<option value=\"All\">All</option></select>"
    end
  end

  describe "annotation_geotype_dropdown" do
    it "should return a select tag" do
      helper.annotation_geotype_dropdown("").should == "<select id=\"geotype\" name=\"geotype\"><option value=\"All\">All</option>\n<option value=\"Platform\">Platform</option>\n<option value=\"Dataset\">Dataset</option>\n<option value=\"Series\">Series</option>\n<option value=\"Sample\">Sample</option></select>"
    end
  end

  describe "cloud_sample_count" do
    it "should return a '' string if count < 0" do
      helper.cloud_sample_count(50, -1).should == nil
    end

    it "should return a string with the count" do
      helper.cloud_sample_count(50, 50).should == "Has annotations that reference 50 GEO accession IDs."
    end

    it "should add that it only returned the first 100 rows" do
      helper.cloud_sample_count(100, 200).should == "Has annotations that reference 200 GEO accession IDs. Limited to the first 100 records."
    end
  end

end
