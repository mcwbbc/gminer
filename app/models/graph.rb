class Graph

  attr_accessor :array, :options, :series

  # due to google only accepting a max height of 1000px, we need to make sure
  # that any graph we create has less than 48 elements. If it's larger, we need
  # to chunk it into multiple graphs, which looks odd since they don't line up
  # correctly on the left side

  def initialize(array, options={})
    @options = set_options(options, array.size)
    data, terms = create_data_terms(array)
    @options[:x_axis] = set_x_labels(terms)
    @options[:y_axis] = set_y_labels
    @series = generate_series(data)
  end

  def set_x_labels(terms)
    {
      :categories => terms
    }
  end

  def set_y_labels(text="Count")
    {
      :min => 0,
      :title => {
        :text => text
      }
    }
  end

  def set_options(options, elements)
    {
      :series_type => 'bar',
      :height => (elements*40)+100,
      :title => "",
      :legend => {
        :layout => "vertical",
        :style => {
          :position => 'absolute',
          :bottom => 'auto',
          :left => 'auto',
          :top => '0px',
          :right => "50px"
        },
        :shadow => false,
        :backgroundColor => '#fff',
        :borderWidth => 1,
      },
      :plot_options => {
        :bar => {
          :dataLabels => {
            :enabled => true,
            :color => 'auto'
          }
        }
      },
      :tooltip_formatter => "function() { return '<b>'+ this.x +'</b><br/>'+ this.series.name +': '+ this.y;}",
      :credits => {
        :enabled => false
      }
    }.merge!(options)
  end

  def generate_series(data)
    series = []
    series << {:name => 'present', :data => data[:present]}
    series << {:name => 'absent', :data => data[:absent]}
    series << {:name => 'marginal', :data => data[:marginal]}
    series
  end

  def create_data_terms(array)
    data = {:present => [], :absent => [], :marginal => []}
    terms = []
    array.each do |item|
      terms << item[:term].name
      data[:present] << item[:present_count].to_i
      data[:absent] << item[:absent_count].to_i
      data[:marginal] << item[:marginal_count].to_i
    end
    [data, terms]
  end

end
