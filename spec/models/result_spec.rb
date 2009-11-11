require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Result do

  describe "page" do
    it "should call paginate" do
      Result.should_receive(:paginate).with({:per_page=>20, :order => "probesets.name", :conditions=>"conditions", :page=>2, :joins => [:sample, :ontology_term, :probeset]}).and_return(true)
      Result.page("conditions", 2, 20)
    end
  end

end