class Result < ActiveRecord::Base
  extend Utilities::ClassMethods

  validates_uniqueness_of :probeset_id, :scope => :sample_id
  validates_uniqueness_of :ontology_term_id, :scope => [:sample_id, :probeset_id]

  belongs_to :sample
  belongs_to :ontology_term
  belongs_to :probeset

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => "probesets.name",
               :conditions => conditions,
               :joins => [:sample, :ontology_term, :probeset],
               :page => page,
               :per_page => size
               )
    end
  end

  def generate_rdf
    ontology_term_to_probeset_name
  end

  def probeset_name_to_pubmed_id
    if !pubmed_id.blank?
      [probeset_name_url, expressed_in_url, pubmed_id_url, "."].join(" ")+"\n"
    else
      ""
    end
  end

  def ontology_term_to_geo_accession
    [ontology_term_url, expressed_in_url, geo_accession_url, "."].join(" ")+"\n"
  end

  def probeset_name_to_geo_accession
    [probeset_name_url, expressed_in_url, geo_accession_url, "."].join(" ")+"\n"
  end

  def ontology_term_to_probeset_name
    [ontology_term_url, expressed_in_url, probeset_name_url, "."].join(" ")+"\n"
  end

  def expressed_in_url
    "<#{Constants::RDF_BIO}gminer#expressedIn>"
  end

  def geo_accession_url
    "<http://www.ncbi.nlm.nih.gov/geo##{sample.geo_accession}>"
  end

  def pubmed_id_url
    "<#{Constants::RDF_BIO}pubmed:#{pubmed_id}>"
  end

  def probeset_name_url
    "<#{Constants::RDF_BIO}affymetrix:#{probeset.name}>"
  end

  def ontology_term_url
    ncbo_id, term_id = ontology_term.term_id.split("|")
    case ncbo_id
      when "MSH"
        "<#{Constants::RDF_MESH}##{term_id}>"
      when "1150" # rat strain
        "<http://rgd.mcw.edu/strains##{term_id}>"
      when "1070" #go
        "<http://www.geneontology.org/terms##{term_id}>"
      when "1000" #mouse gross anatomy
        "<#{Constants::RDF_BIO}#{term_id.downcase}>"
      when "1035" #pathway
        "<http://purl.org/obo/owl/PW##{term_id.gsub(":", "_")}>"
      when "1032" #NCI Thesaurus
        "<http://purl.org/obo/owl/NCIt#NCIt_#{term_id}>"
      when "1025" #Mammalian Phenotype
        "<http://purl.org/obo/owl/MP##{term_id.gsub(":", "_")}>"
    end
  end
end
