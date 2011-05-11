namespace :persist do

  desc "Load the default Ontologies"
  task(:ontology, :needs => :environment) do |t, args|
    Constants::ONTOLOGIES.keys.each do |key|
      if (key != "all")
        if o = Ontology.find(:first, :conditions => {:ncbo_id => key})
          o.version = Constants::ONTOLOGIES[key][:version]
          o.current_ncbo_id = Constants::ONTOLOGIES[key][:current_ncbo_id]
        else
          o = Ontology.new(:ncbo_id => key, :name => Constants::ONTOLOGIES[key][:name], :version => Constants::ONTOLOGIES[key][:version], :stopwords => Constants::ONTOLOGIES[key][:stopwords], :current_ncbo_id => Constants::ONTOLOGIES[key][:current_ncbo_id])
        end
        o.save
      end
    end
  end

  desc "Create, download and persist the platform"
  task(:platform, :needs => :environment) do |t, args|
    full = ENV['full'] ? ENV['full'] : false
    force = ENV['force'] ? ENV['force'] : false
    geo_accession = ENV['geo_accession']
    if (geo_accession =~ /^GPL\d+$/)
      p = Gminer::Platform.persist(geo_accession, force)
      mp = Mongo::Platform.persist(geo_accession, force)
      if full
        p.create_series
        mp.create_series
      end
    else
      puts "You must supply a proper platform GEO accession number (ex. GPL1234)"
    end
  end

  desc "Persist the dataset"
  task(:dataset, :needs => :environment) do |t, args|
    geo_accession = ENV['geo_accession']
    if (geo_accession =~ /^GDS\d+$/)
      ds = Dataset.persist(geo_accession)
      mds = Mongo::Dataset.persist(geo_accession)
    else
      puts "You must supply a proper dataset GEO accession number (ex. GDS1234)"
    end
  end

  desc "Create the series, samples and detections"
  task(:series, :needs => :environment) do |t, args|
    platform_geo_accession = ENV['platform_geo_accession']
    p = Gminer::Platform.first(:conditions => {:geo_accession => platform_geo_accession})
    if p
      array = ENV['array']
      if array
        if array == "all"
          p.create_series # this will load the soft file and pull down all the series
        else
          accessions = array.split(",")
          flag = accessions.inject(true) { |f, accession| f = f && !!(accession =~ /^GSE\d+$/); f}
          if flag
            p.create_series(accessions)
          else
            puts "Invalid GEO accessions. Please use rake install:series[GPL1234] array=GSE123,GSE234,GSE345,GSE456"
          end
        end
      else
        puts "No array included. Please use rake install:series[GPL1234] array=GSE123,GSE234,GSE345,GSE456"
      end
    else
      puts "The platform doesn't exist in the database. Please persist the platform first."
    end
  end
end
