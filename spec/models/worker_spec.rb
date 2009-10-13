require File.dirname(__FILE__) + '/../spec_helper'

describe Worker do
  describe "available" do
    it "should find the first available worker" do
      worker = Worker.generate(:worker_key => 'worker-1234')
      Worker.should_receive(:available).and_return(worker)
      Worker.available.should == worker
    end
  end
end
