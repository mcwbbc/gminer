namespace :parse do

  desc "Insert the obo terms into the database"
  task :obo, :ncbo_id, :filename, :needs => :environment do |t, args|
    filename = args.filename
    ncbo_id = args.ncbo_id
    if !ncbo_id.blank? && !filename.blank? && File.exists?(filename)
      puts "Inserting #{filename} for ncbo id #{ncbo_id}"
      Ontology.insert_terms(filename, ncbo_id)
    else
      p "You must include the ncbo id and file to parse. EX: rake parse:obo[1150,metadata/strainont_6_21_10_v2.1]"
    end
  end

  desc "Insert the RGD genes into the database"
  task :rgd_gene, :filename, :needs => :environment do |t, args|
    filename = args.filename
    if !filename.blank? && File.exists?(filename)
      puts "Inserting #{filename}"
      Probeset.insert_rgd_genes(filename)
    else
      p "You must include the file to parse. EX: rake parse:rgd_gene[metadata/affy_probeset_id_rgd_gene.txt]"
    end
  end

  desc "Update the symbols in the database for RGD gene id"
  task :gene_symbol, :filename, :needs => :environment do |t, args|
    filename = args.filename
    if !filename.blank? && File.exists?(filename)
      puts "Updating for #{filename}"
      CSV.foreach(filename) do |line|
        rgd_gene, symbol = line
#        puts "#{rgd_gene}->#{symbol}"
        Probeset.update_all("symbol = '#{symbol}'", "rgd_gene = '#{rgd_gene}'")
      end
    else
      p "You must include the file to parse. EX: rake parse:rgd_gene[metadata/rgdgene_symbol.csv]"
    end
  end

end