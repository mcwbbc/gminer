require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Detection do

  describe "present?" do
    it "should be true if 'P'" do
      d = Factory.build(:detection)
      d.present?.should == true
    end

    it "should be false if not 'P'" do
      d = Factory.build(:detection, :abs_call => "A")
      d.present?.should == false
    end
  end

end
