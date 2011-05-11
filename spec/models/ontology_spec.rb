require 'spec_helper'

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
      Ontology.should_receive(:paginate).with({:conditions=>"conditions", :order => :name, :page=>2, :per_page=>20}).and_return(true)
      Ontology.page("conditions", 2, 20)
    end
  end

  describe "which have annotations" do
    it "should only return the ontologies that have annotations" do
      o1 = Factory.build(:ontology)
      o1.should_receive(:annotations).and_return(["annotation"])
      o2 = Factory.build(:ontology)
      o2.should_receive(:annotations).and_return([])
      Ontology.should_receive(:all).with(:order => :name).and_return([o1, o2])
      Ontology.which_have_annotations.should == [o1]
    end
  end

  describe "update data" do
    it "should update the ontology data from NCBO" do
      ontology = Factory.build(:ontology)
      ontology.should_receive(:save!).and_return(true)
      NCBOAnnotatorService.should_receive(:current_ncbo_id).with(ontology.ncbo_id).and_return(["new_ncbo", "new_name", "new_version"])
      ontology.update_data
    end
  end

end
