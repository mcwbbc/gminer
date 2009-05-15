require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe AnnotationClosure do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    AnnotationClosure.create!(@valid_attributes)
  end
end
