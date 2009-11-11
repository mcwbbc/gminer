require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Detection do

  describe "page" do
    it "should call paginate" do
      Detection.should_receive(:paginate).with({:order => "probesets.name", :conditions=>"conditions", :page=>2, :joins => [:sample, :probeset], :per_page=>20}).and_return(true)
      Detection.page("conditions", 2, 20)
    end
  end

  describe "present?" do
    it "should be true if 'P'" do
      d = Detection.spawn
      d.present?.should == true
    end

    it "should be false if not 'P'" do
      d = Detection.spawn(:abs_call => "A")
      d.present?.should == false
    end
  end

end
