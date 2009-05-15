require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Result do

  describe "page" do
    it "should call paginate" do
      Result.should_receive(:paginate).with({:per_page=>20, :order=>[:sample_geo_accession, :id_ref, :ontology_term_id], :conditions=>"conditions", :page=>2}).and_return(true)
      Result.page("conditions", 2, 20)
    end
  end

end