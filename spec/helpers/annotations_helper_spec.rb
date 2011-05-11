require 'spec_helper'

describe AnnotationsHelper do

  #Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(AnnotationsHelper)
  end

  describe "ontology_search_dropdown" do
    it "should return a select tag" do
      ontology = Factory.build(:ontology)
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
    describe "with ignore all" do
      it "should return a select tag" do
        helper.annotation_geotype_dropdown("", true).should == "<select id=\"geotype\" name=\"geotype\"><option value=\"Platform\">Platform</option>\n<option value=\"Dataset\">Dataset</option>\n<option value=\"Series\">Series</option>\n<option value=\"Sample\">Sample</option></select>"
      end
    end

    describe "without ignore all" do
      it "should return a select tag" do
        helper.annotation_geotype_dropdown("").should == "<select id=\"geotype\" name=\"geotype\"><option value=\"All\">All</option>\n<option value=\"Platform\">Platform</option>\n<option value=\"Dataset\">Dataset</option>\n<option value=\"Series\">Series</option>\n<option value=\"Sample\">Sample</option></select>"
      end
    end
  end

  describe "cloud_sample_count" do
    describe "with 1 term" do
      it "should return a '' string if count == 0" do
        helper.cloud_sample_count(0).should == nil
      end

      it "should return a string with the count" do
        helper.cloud_sample_count(50).should == "annotations reference 50 GEO records."
      end

      it "should return a string with the count of one" do
        helper.cloud_sample_count(1).should == "annotations reference 1 GEO record."
      end
    end
  end

end
