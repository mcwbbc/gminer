
class Graph

  attr_accessor :arrays, :max_value, :max_term_size

  # due to google only accepting a max height of 1000px, we need to make sure
  # that any graph we create has less than 48 elements. If it's larger, we need
  # to chunk it into multiple graphs, which looks odd since they don't line up
  # correctly on the left side

  def initialize(array)
    # chunk is in lib/patch.rb
    @arrays = (array.size > 10) ? array.chunk((array.size/10)+1) : [array]
    @max_value = get_max_value(array)
    @max_term_size = get_max_term_size(array)
  end

  def generate
    html = ""
    arrays.each do |array|
      legend = ["present", "absent", "marginal"]
      data, terms = create_data_terms(array)

      height, width = create_height_width(array)

      html << Gchart.bar(:size => "#{width}x#{height}",
                 :data => data,
                 :legend => legend,
                 :bar_width_and_spacing => '10,2,10',
                 :orientation => 'horizontal',
                 :bar_colors => '00FF00,FF0000,0000FF',
                 :max_value => @max_value,
                 :stacked => false,
                 :axis_with_labels => 'y,x',
                 :axis_labels => [terms, x_labels(@max_value)],
                 :custom => "chg=10,0",
                 :format => 'image_tag',
                 :encoding => 'extended')+"<br />"
    end
    html
  end

  def create_height_width(array)
    h = (array.size+2)*30
    height = (h > 1000) ? 1000 : h
    w = (300000/height)
    width =  (w > 300) ? (w > 1000) ? 1000 : w : 300
    [height, width]
  end

  def get_max_term_size(array)
    term_size = 0
    array.each do |item|
      term_size = item[:term].name.size if (item[:term].name.size > term_size)
    end
    term_size
  end

  def get_max_value(array)
    max_array = []
    array.each do |item|
      max_array << item[:present_count].to_i
      max_array << item[:absent_count].to_i
      max_array << item[:marginal_count].to_i
    end
    max_array.flatten.uniq.max
  end

  def create_data_terms(array)
    data = [[],[],[]]
    terms = []
    array.each do |item|
      terms << item[:term].name.rjust(max_term_size)
      data[0] << item[:present_count].to_i
      data[1] << item[:absent_count].to_i
      data[2] << item[:marginal_count].to_i
    end
    [data, terms.reverse]
  end

  def x_labels(max)
    labels = (1..9).inject(["0"]) do |a, v|
      a << ("%.2f" % (max.to_f/10.0*v)).to_s
      a
    end
    labels << max
  end

end
