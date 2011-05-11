require 'spec_helper'

describe Graph do

  def get_mock(id)
    {:term => Factory.build(:ontology_term), :present_count => id, :absent_count => 0, :marginal_count => 0, :total_count => 7}
  end

  describe "set axis labels" do
    before(:each) do
      @array = []
      1.upto(2).each do |i|
        @array << get_mock(i)
      end
      @g = Graph.new(@array)
    end

    it "should set up the x labels" do
      @g.options[:x_axis][:categories].size.should == 2
    end

    it "should set up the y labels" do
      @g.options[:y_axis].should == {:title=>{:text=>"Count"}, :min=>0}
    end

    it "should set up the series" do
      @g.series.should == [{:data=>[1, 2], :name=>"present"}, {:data=>[0, 0], :name=>"absent"}, {:data=>[0, 0], :name=>"marginal"}]
    end
  end

  describe "create_data_terms" do
    before(:each) do
      @array = []
      1.upto(2).each do |i|
        @array << get_mock(i)
      end
      @g = Graph.new(@array)
    end

    it "should return the data, terms" do
      @g.create_data_terms(@array).should == [{:present => [1, 2], :absent => [0, 0], :marginal => [0, 0]}, [@array[0][:term].name, @array[1][:term].name]]
    end
  end

end
