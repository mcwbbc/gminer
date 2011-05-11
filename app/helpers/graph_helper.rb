module GraphHelper

  def high_graph(div_name, chart)
    graph = javascript_tag <<-EOJS
      $(document).ready(function() {
        var chart = new Highcharts.Chart({
          chart: {
             renderTo: '#{div_name}',
             defaultSeriesType: '#{chart.options[:series_type]}',
             height: '#{chart.options[:height]}',
             margin: [50, 50, 60, 200]
           },
          title: #{chart.options[:title].to_json},
          legend: #{chart.options[:legend].to_json},
          xAxis: #{chart.options[:x_axis].to_json},
          yAxis: #{chart.options[:y_axis].to_json},
          tooltip: { formatter: #{chart.options[:tooltip_formatter]} },
          credits: #{chart.options[:credits].to_json},
          plotOptions: #{chart.options[:plot_options].to_json},
          series: #{chart.series.to_json}
         });
      });
    EOJS
  end

  def high_pie(div_name, pie)
    graph = javascript_tag <<-EOJS
      $(document).ready(function() {
        var chart = new Highcharts.Chart({
          chart: {
             renderTo: '#{div_name}',
           },
          title: { text: #{pie.options[:title].to_json} },
          legend: #{pie.options[:legend].to_json},
          tooltip: { formatter: #{pie.options[:tooltip_formatter]} },
          credits: #{pie.options[:credits].to_json},
          plotOptions: #{pie.options[:plot_options].to_json},
          series: #{pie.series.to_json}
         });
      });
    EOJS
  end
end
