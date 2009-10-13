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

end
