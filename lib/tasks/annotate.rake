namespace :annotate do
  desc "Annotate the platforms"
  task(:platforms, :needs => :environment) do
    annotate(Platform)
  end

  desc "Annotate the datasets"
  task(:datasets, :needs => :environment) do
    annotate(Dataset)
  end

  desc "Annotate the series"
  task(:series, :needs => :environment) do
    annotate(SeriesItem)
  end

  desc "Annotate the samples"
  task(:samples, :needs => :environment) do
    annotate(Sample)
  end

  desc "Clean the annotations based on keywords"
  task(:clean, :needs => :environment) do
    array = ENV['terms']
    if array
      terms = array.split(",")
      terms.each do |term|
        while r = OntologyTerm.first(:name => term)
          r.annotation_closures.clear
          r.annotations.clear
          r.destroy
        end
      end
    else
      puts "No array included. Please use rake annotate:clean terms=A,B,C"
    end
  end

  desc "Annotate all the items"
  task(:create_jobs => [:platforms, :datasets, :series, :samples])

  def annotate(model)
    model.all.each do |geo_item|
      Job.create_for(geo_item.geo_accession)
    end
  end
end