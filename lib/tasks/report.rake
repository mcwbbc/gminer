namespace :report do

  desc "Show manual annotation text and terms"
  task(:manual_annotation_terms, :needs => :environment) do |t, args|
    output_results
  end

  def output_results
    CSV.open("tmp/manual_annotation_terms.csv", "w") do |csv|
      # header row
      csv << ["term_name", "term_id", "term_text", "ncbo_id", "geo_accession", "field_name", "from", "to"]
      AnnotationReport.manual_terms.each do |term|
        csv << [term[:term_name], term[:term_id], term[:term_text], term[:ncbo_id], term[:geo_accession], term[:field_name], term[:from], term[:to]]
      end
    end
  end

  desc "Show jobs with parameters"
  task(:job_parameters, :needs => :environment) do |t, args|
    job_parameters
  end

  def job_parameters
    CSV.open("tmp/job_parameters.csv", "w") do |csv|
      # header row
      csv << ["geo_accession", "field_name", "stopWords", "ontologiesToKeepInResult", "textToAnnotate"]
      Job.all.each do |job|
        item = Job.load_item(job.geo_accession)
        stopwords = Constants::STOPWORDS+job.ontology.stopwords
        if item.send(job.field_name).blank?
          csv << [job.geo_accession, job.field_name, stopwords, job.ontology.ncbo_id, ""]
        else
          csv << [job.geo_accession, job.field_name, stopwords, job.ontology.ncbo_id, item.send(job.field_name)]
        end
      end
    end
  end

  desc "Show annotations that are multiples for the same text"
  task(:multiple_annotations, :needs => :environment) do |t, args|
    multiple_annotations
  end

  def multiple_annotations
    header_row = ["geo_accession", "field_name", "matched_text", "ontology_term", "ontology", "ontology_virtual_id"]
    CSV.open("tmp/multiple_annotations.csv", "w") do |csv|
      # header row
      csv << header_row
      Annotation.find_by_sql("select count(*) as count, geo_accession, field_name, `from`, `to` from annotations group by geo_accession, field_name, `from`, `to` having count > 1 order by count desc").each do |a|
        Annotation.all(:conditions => ["geo_accession = '#{a.geo_accession}' and field_name = '#{a.field_name}' and `from` = #{a.from} and `to` = #{a.to}"]).each do |annotation|
          csv << [annotation.geo_accession, annotation.field_name, annotation.term_text, annotation.ontology_term.name, annotation.ontology.name, annotation.ncbo_id]
        end
        csv << [] # add a blank row
      end

    end
  end

end



