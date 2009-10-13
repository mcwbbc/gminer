namespace :generate do

  desc "Generate jobs for the models"
  task(:jobs, :needs => :environment ) do
    item = ENV['item']
    ontology_id = ENV['ontology_id']
    field = ENV['field']
    if item && ontology_id && field
      ontology = Ontology.first(:conditions => {:ncbo_id => ontology_id})
      if ontology
        model = Kernel.const_get(item)
        model.find_in_batches(:select => "id, geo_accession") do |group|
          group.each do |geo_item|
            Job.create_for(geo_item.geo_accession, ontology.id, field)
          end
        end
      else
        p "You need to a valid ontology id."
      end
    else
      p "You need to include an item, ncbo id and field."
    end
  end

  desc "Generate results for ontology term, ontology and field"
  task(:results, :term, :ontology_name, :field, :needs => :environment) do |t, args| 
    hash = {:term => args.term}
    hash[:ontology_name] = args.ontology_name if args.ontology_name
    hash[:field] = args.field if args.field
    hash[:debug] = ENV['debug']
    puts hash
    Sample.create_results(hash)
  end
  
  desc "Generate rdf for results"
  task(:rdf, :filename, :needs => :environment) do |t, args| 
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

