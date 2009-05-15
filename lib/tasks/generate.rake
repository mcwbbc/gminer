namespace :generate do

  desc "Generate results for ontology term, ontology and field"
  task(:results, :term, :ontology_name, :field, :needs => :merb_env) do |t, args| 
    hash = {:term => args.term}
    hash[:ontology_name] = args.ontology_name if args.ontology_name
    hash[:field] = args.field if args.field
    hash[:debug] = ENV['debug']
    puts hash
    Sample.create_results(hash)
  end
  
  desc "Generate rdf for results"
  task(:rdf, :filename, :needs => :merb_env) do |t, args| 
    filename = args.filename
    create_rdf(filename)
  end

  def create_rdf(filename, batch_size=1000)
    Result.find_in_batches(:batch_size => batch_size) do |records|
      File.open(filename, 'a') do |out|
        records.each do |record|
          out.write(record.generate_rdf)
        end
      end
    end
  end
  
end

