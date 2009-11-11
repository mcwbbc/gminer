require File.dirname(__FILE__) + '/../spec_helper'

describe Graph do

  def get_mock(id)
    {:term => OntologyTerm.spawn, :present_count => id, :absent_count => 0, :marginal_count => 0, :total_count => 7}
  end

  describe "new" do
    it "should not chunk the array" do
      array = (1..10).map { |n| get_mock(n) }
      g = Graph.new(array)
      g.arrays.size.should == 1
    end

    it "should chunk the array into 6" do
      array = (1..50).map { |n| get_mock(n) }
      g = Graph.new(array)
      g.arrays.size.should == 6
    end

    it "should chunk the array into 10" do
      array = (1..95).map { |n| get_mock(n) }
      g = Graph.new(array)
      g.arrays.size.should == 10
    end
  end

  describe "create_height_width" do
    it "should return normal height width" do
      array = (1..20).map { |n| get_mock(n) }
      g = Graph.new(array)
      g.create_height_width(array).should == [660, 454]
    end

    it "should clip the height to 1000" do
      array = (1..50).map { |n| get_mock(n) }
      g = Graph.new(array)
      g.create_height_width(array).should == [1000, 300]
    end

    it "should force the width to 1000" do
      array = (1..1).map { |n| get_mock(n) }
      g = Graph.new(array)
      g.create_height_width(array).should == [90, 1000]
    end
  end

  describe "x_labels" do
    before(:each) do
      @array = (1..1).map { |n| get_mock(n) }
      @g = Graph.new(@array)
    end

    it "should generate 10 text labels to max" do
      @g.x_labels(10).should == ["0", "1.00", "2.00", "3.00", "4.00", "5.00", "6.00", "7.00", "8.00", "9.00", 10]
    end

    it "should generate 10 text labels to max including fractions" do
      @g.x_labels(6).should == ["0", "0.60", "1.20", "1.80", "2.40", "3.00", "3.60", "4.20", "4.80", "5.40", 6]
    end
  end

  describe "get_max_term_size" do
    it "should return the max term size" do
      @array = []
      1.upto(5).each do |i|
        @array << get_mock(i)
      end
      @g = Graph.new(@array)
      @g.get_max_term_size(@array).should == 2
    end
  end

  describe "get_max_value" do
    it "should return the max value" do
      @array = []
      1.upto(5).each do |i|
        @array << get_mock(i)
      end
      @g = Graph.new(@array)
      @g.get_max_value(@array).should == 5
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
      @g.create_data_terms(@array).should == [[[1, 2], [0, 0], [0, 0]], [@array[1][:term].name, @array[0][:term].name]]
    end
  end

  describe "generate" do
    it "should create html for a single array" do
      array = (1..10).map { |n| get_mock(n) }
      g = Graph.new(array)
      Gchart.should_receive(:bar).and_return("image1")
      g.should_receive(:create_data_terms)
      g.should_receive(:create_height_width)
      g.generate.should == "image1<br />"
    end

    it "should create html for a multiple arrays" do
      array = (1..50).map { |n| get_mock(n) }
      g = Graph.new(array)
      g.should_receive(:create_data_terms).at_least(6).times
      g.should_receive(:create_height_width).at_least(6).times
      Gchart.should_receive(:bar).and_return("image1", "image2", "image3", "image4", "image5", "image6")
      g.generate.should == "image1<br />image2<br />image3<br />image4<br />image5<br />image6<br />"
    end
  end


end
