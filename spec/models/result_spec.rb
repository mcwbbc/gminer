require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Result do

  describe "page" do
    it "should call paginate" do
      Result.should_receive(:paginate).with({:per_page=>20, :order => "samples.geo_accession, id_ref, ontology_terms.term_id", :conditions=>"conditions", :page=>2, :include => [:sample, :ontology_term]}).and_return(true)
      Result.page("conditions", 2, 20)
    end
  end

end