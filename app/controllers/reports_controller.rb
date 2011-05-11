class ReportsController < ApplicationController

  before_filter :admin_required

  def index
  end

  def progress
    @result_hash = ProgressReport.results
  end

  def comparison
    set_date_dropdown
    @result_hash = ComparisonReport.results(@comparison_date)

    @comparison_field_name_hash = Comparison.get_field_name_hash(@comparison_date)

    respond_to do |format|
      format.html { }
      format.js  {
          render(:partial => "reports/comparison_report.html.haml")
        }
      format.xml  {}
      format.csv  {}
    end
  end

  def annotation
    set_ontology_dropdown
    set_geotype_dropdown

    report = AnnotationReport.new
    report.setup(@ontology, @geotype)

    @fields, @result_hash = report.results

    respond_to do |format|
      format.html { }
      format.js  {
          render(:partial => "reports/annotation_report.html.haml")
        }
    end
  end

  def manual_annotation_terms

    respond_to do |format|
      format.html { }
      format.csv  {
        @terms = AnnotationReport.manual_terms
        csv_string = CSV.generate do |csv|
          # header row
          csv << ["term_name", "term_id", "term_text", "ncbo_id", "geo_accession", "field_name", "from", "to"]
          @terms.each do |term|
            csv << [term[:term_name], term[:term_id], term[:term_text], term[:ncbo_id], term[:geo_accession], term[:field_name], term[:from], term[:to]]
          end
        end
        filename = "manual_annotation_terms"
        # send it to the browsah
        send_data(csv_string.force_encoding('UTF-8'), :type => 'text/csv; charset=UTF-8; header=present', :disposition => "attachment; filename=#{filename}.csv")
      }
    end
  end

  def job_statistics
    @results_hash = Job.get_statistics
    respond_to do |format|
      format.html { }
      format.csv  {
        csv_string = CSV.generate do |csv|
          # header row
          csv << ["detail", "count", "NCBO ave time", "ave time", "min time", "max time"]
          @results_hash.keys.sort.each do |geo_item|
            csv << [geo_item, @results_hash[geo_item][:count], @results_hash[geo_item][:ncbo_average_time], @results_hash[geo_item][:average_time], @results_hash[geo_item][:min_time]]
            if @results_hash[geo_item][:field_names].any?
              @results_hash[geo_item][:field_names].keys.sort.each do |field_name|
                csv << ["#{geo_item}:#{field_name}", @results_hash[geo_item][:field_names][field_name][:count], @results_hash[geo_item][:field_names][field_name][:ncbo_average_time], @results_hash[geo_item][:field_names][field_name][:average_time], @results_hash[geo_item][:field_names][field_name][:min_time], @results_hash[geo_item][:field_names][field_name][:max_time]]
                if @results_hash[geo_item][:field_names][field_name][:ontology_ids].any?
                  @results_hash[geo_item][:field_names][field_name][:ontology_ids].keys.sort.each do |ontology|
                    csv << ["#{geo_item}:#{field_name}:#{@results_hash[geo_item][:field_names][field_name][:ontology_ids][ontology][:name]}", @results_hash[geo_item][:field_names][field_name][:ontology_ids][ontology][:count], @results_hash[geo_item][:field_names][field_name][:ontology_ids][ontology][:ncbo_average_time], @results_hash[geo_item][:field_names][field_name][:ontology_ids][ontology][:average_time], @results_hash[geo_item][:field_names][field_name][:ontology_ids][ontology][:min_time], @results_hash[geo_item][:field_names][field_name][:ontology_ids][ontology][:max_time]]
                  end
                end
              end
            end
          end
        end
        filename = "job_statistics_#{Time.now.to_s(:file)}"
        # send it to the browsah
        send_data(csv_string.force_encoding('UTF-8'), :type => 'text/csv; charset=UTF-8; header=present', :disposition => "attachment; filename=#{filename}.csv")
      }
    end
  end


  protected
    def set_ontology_dropdown
      @ontology = params[:ddown] ? params[:ddown] : Annotation.first ? Annotation.first.ncbo_id : ""
    end

    def set_geotype_dropdown
      @geotype = params[:geotype] ? params[:geotype] : "Platform"
    end

    def set_date_dropdown
      @comparison_date = params[:ddown] ? params[:ddown] : Comparison.get_newest_date
    end

end
