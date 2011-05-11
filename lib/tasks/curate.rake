namespace :curate do

  desc "Clean the annotations based on ontology term length"
  task(:clean, :needs => :environment) do

    x = 0
    Annotation.where(:ncbo_id => 1150).where(:verified => 0).where(:status => 'unaudited').find_in_batches do |annotations|
      puts "#{x}: #{annotations.first.identifier}"
      x += 1000
      annotations.each do |annotation|
        annotation.auto_curate
      end
    end

  end

end