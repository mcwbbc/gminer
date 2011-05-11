namespace :generate do

  desc "Generate annotations from resource index"
  task(:resource_index_annotations, :needs => :environment) do
    Dataset.select('geo_accession').all.each do |dataset|
      if ResourceIndexAnnotation.where(:geo_accession => dataset.geo_accession).empty?
        puts dataset.geo_accession
        hash = NcboResourceService.annotations_for_geo_accession(dataset.geo_accession)
        ResourceIndexAnnotation.save_from_hash(hash)
      else
        puts "Skipping: #{dataset.geo_accession}"
      end
    end
  end

  desc "Generate jobs for the models"
  task(:jobs, :needs => :environment ) do
    item = ENV['item']
    ncbo_id = ENV['ncbo_id']
    fields_string = ENV['fields'] || ""
    fields = fields_string.gsub(" ","").split(",")
    if item && ncbo_id && fields.any?
      ontology = Ontology.first(:conditions => {:ncbo_id => ncbo_id})
      if ontology
        model = item.constantize
        model.find_in_batches(:select => "id, geo_accession") do |group|
          group.each do |geo_item|
            fields.each do |field_name|
              Job.create_for(geo_item.geo_accession, ontology.id, field_name)
            end
          end
        end
      else
        p "You need to a valid ontology id."
      end
    else
      p "You need to parameters like: item=Sample ncbo_id=1000 fields=title,summary"
    end
  end

  desc "Generate results for ontology term, ontology and field_name"
  task(:results, :term_id, :ncbo_id, :field_name, :needs => :environment) do |t, args|
    hash = {}
    hash[:ncbo_id] = args.ncbo_id if args.ncbo_id
    hash[:field_name] = args.field_name if args.field_name
    hash[:term_id] = args.term_id if args.term_id
    hash[:debug] = ENV['debug']
    puts hash
    Sample.create_results(hash)
  end

  desc "Generate rdf for results"
  task(:rdf, :filename, :needs => :environment) do |t, args|
    filename = args.filename
    create_rdf(filename)
  end

  def create_rdf(filename, batch_size=10000)
    Result.find_in_batches(:batch_size => batch_size, :include => [:ontology_term]) do |records|
      File.open(filename, 'a') do |out|
        records.each do |record|
          out.write(record.generate_rdf)
        end
      end
    end
  end

end

