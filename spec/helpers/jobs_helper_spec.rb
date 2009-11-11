require 'spec_helper'

describe JobsHelper do

  #Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(JobsHelper)
  end

  describe "job status dropdown" do
    it "should return a select tag with selected" do
      helper.job_status_dropdown("Active").should == "<select id=\"status\" name=\"status\"><option value=\"Pending\">Pending</option>\n<option value=\"Active\" selected=\"selected\">Active</option>\n<option value=\"Finished\">Finished</option></select>"
    end

    it "should return a select tag without selected" do
      helper.job_status_dropdown("").should == "<select id=\"status\" name=\"status\"><option value=\"Pending\">Pending</option>\n<option value=\"Active\">Active</option>\n<option value=\"Finished\">Finished</option></select>"
    end
  end

  describe "date or pending" do
    it "should return pending without a date" do
      helper.date_or_pending(nil).should == "Pending"
    end

    it "should return formatted date" do
      now = Time.now
      helper.date_or_pending(now).should == now.to_s(:us_with_time)
    end
  end

end
