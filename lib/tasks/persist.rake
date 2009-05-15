namespace :persist do

  desc "Load the default Ontologies"
  task(:ontology, :needs => :merb_env) do |t, args|  
    Constants::ONTOLOGIES.keys.each do |key|
      o = Ontology.new(:ncbo_id => key, :name => Constants::ONTOLOGIES[key][:name], :version => Constants::ONTOLOGIES[key][:version] )
      o.save
    end
  end

  desc "Setup the triggers"
  task(:triggers, :needs => :merb_env) do |t, args|  
    inc_sql = "CREATE TRIGGER inc_annotation_count AFTER INSERT ON annotations FOR EACH ROW UPDATE ontology_terms SET annotations_count = annotations_count+1 WHERE ontology_terms.term_id = NEW.ontology_term_id;"
    repository(:default).adapter.execute(inc_sql)
    dec_sql = "CREATE TRIGGER dec_annotation_count AFTER DELETE ON annotations FOR EACH ROW UPDATE ontology_terms SET annotations_count = annotations_count-1 WHERE ontology_terms.term_id = OLD.ontology_term_id;"
    repository(:default).adapter.execute(dec_sql)
  end

  desc "Create, download and persist the platform"
  task(:platform, :geo_accession, :needs => :merb_env) do |t, args|  
    if (args.geo_accession =~ /^GPL\d+$/)
      p = Platform.persist(args.geo_accession)
    else
      puts "You must supply a proper platform GEO accession number (ex. GPL1234)"
    end
  end
  
  desc "Persist the dataset"
  task(:dataset, :geo_accession, :needs => :merb_env) do |t, args|  
    if (args.geo_accession =~ /^GDS\d+$/)
      ds = Dataset.persist(args.geo_accession)
    else
      puts "You must supply a proper dataset GEO accession number (ex. GDS1234)"
    end
  end
  
  desc "Create the series, samples and detections"
  task(:series, :platform_geo_accession, :needs => :merb_env) do |t, args|  
    p = Platform.first(:geo_accession => args.platform_geo_accession)
    if p
      array = ENV['array']
      if array
        accessions = array.split(",")
        flag = accessions.inject(true) { |f, accession| f = f && !!(accession =~ /^GSE\d+$/); f} 
        if flag
          p.create_series(accessions)
        else
          puts "Invalid GEO accessions. Please use rake install:series[GPL1234] array=GSE123,GSE234,GSE345,GSE456"
        end
      else
        puts "No array included. Please use rake install:series[GPL1234] array=GSE123,GSE234,GSE345,GSE456"
      end
    else
      puts "The platform doesn't exist in the database. Please persist the platform first."
    end
  end
end
