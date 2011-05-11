require 'spec_helper'

include ApplicationHelper

describe ProbesetsHelper do

  #Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ProbesetsHelper)
  end

  describe "probeset_platform_links" do
    it "should return a string of links concatinated by <br /> tags" do
      p1 = Factory.build(:platform)
      p2 = Factory.build(:platform, :geo_accession => "GPL1", :title => "title")
      helper.probeset_platform_links([p1, p2]).should == "<a href=\"http://test.host/platforms/GPL1355\" target=\"\">GPL1355</a> - Platform Title<br /><a href=\"http://test.host/platforms/GPL1\" target=\"\">GPL1</a> - title"
    end
  end

end
