require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe NCBOException do

  it "should output as a string" do
    e = NCBOException.new("crash!", "parameters")
    e.to_s.should == "crash! (parameters)"
  end

end
