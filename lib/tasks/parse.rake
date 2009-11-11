namespace :parse do

  desc "Insert the obo terms into the database"
  task(:obo, :needs => :environment) do
    file = ENV['file']
    ncbo_id = ENV['ncbo_id']
    if !ncbo_id.blank? && !file.blank? && File.exists?(file)
      Ontology.insert_terms(file, ncbo_id)
    else
      p "You must include the ncbo id and file to parse"
    end
  end

end