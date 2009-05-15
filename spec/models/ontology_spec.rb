require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Ontology do

  describe "create" do
    [:name].each do |key|
      it "should not create a new instance without '#{key}'" do
        Factory.build(:ontology, key => nil).should_not be_valid
      end
    end
  end

  describe "page" do
    it "should call paginate" do
      Ontology.should_receive(:paginate).with({:conditions=>"conditions", :order => [:name], :page=>2, :per_page=>20}).and_return(true)
      Ontology.page("conditions", 2, 20)
    end
  end

end
