namespace :annotate do
  desc "Annotate the platforms"
  task(:platforms, :needs => :merb_env) do
    annotate(Platform)
  end

  desc "Annotate the datasets"
  task(:datasets, :needs => :merb_env) do
    annotate(Dataset)
  end

  desc "Annotate the series"
  task(:series, :needs => :merb_env) do
    annotate(SeriesItem)
  end

  desc "Annotate the samples"
  task(:samples, :needs => :merb_env) do
    annotate(Sample)
  end

  desc "Clean the annotations based on keywords"
  task(:clean, :needs => :merb_env) do
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
  task(:all => [:platforms, :datasets, :series, :samples])

  def annotate(model)
    model.all.each do |item| 
      item.create_annotations
    end
  end
  
end