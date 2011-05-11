class PieChart

  attr_accessor :array, :options, :series

  # due to google only accepting a max height of 1000px, we need to make sure
  # that any graph we create has less than 48 elements. If it's larger, we need
  # to chunk it into multiple graphs, which looks odd since they don't line up
  # correctly on the left side

  def initialize(array, options={})
    @options = set_options(options)
    @series = generate_series(array)
  end

  def set_options(options)
    {
      :legend => {
        :layout => "vertical",
        :style => {
          :bottom => 'auto',
          :left => 'auto',
          :top => '40px',
          :right => "20px"
        },
        :shadow => false,
        :backgroundColor => '#fff',
        :borderWidth => 1,
      },
      :plot_options => {
        :pie => {
          :dataLabels => {
            :enabled => true,
            :color => 'white'
          }
        }
      },
      :tooltip_formatter => "function() { return '<b>'+ this.point.name +'</b>: '+ this.y +' %'}",
      :credits => {
        :enabled => false
      }
    }.merge!(options)
  end

  def generate_series(data) # data is array of arrays [['label', value], ['label', value]]
    series = {:type => 'pie', :name => "Annotation status"}
    series[:data] = data
    [series]
  end

end
