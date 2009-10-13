class Constants

  MODEL_GEO_PREFIXES = {
                        "Dataset" => "GDS",
                        "Sample" => "GSM",
                        "Platform" => "GPL",
                        "SeriesItem" => "GSE"
                        }
  
  ONTOLOGIES = {
                "1032" => {
                  :name => "NCI Thesaurus",
                  :version => "08.12d",
                  :current_ncbo_id => "39478",
                  :stopwords => ""
                  },
                "MSH" => {
                  :name => "Medical Subject Headings, 2009_2008_08_06",
                  :version => "2009_2008_08_06",
                  :current_ncbo_id => "MSH",
                  :stopwords => ""
                  },
                "1070" => {
                  :name => "Gene Ontology", 
                  :version => "1.511",
                  :current_ncbo_id => "39917",
                  :stopwords => ""
                  },
                "1150" => {
                  :name => "Rat Strain Ontology",
                  :version => "1.0",
                  :current_ncbo_id => "39234",
                  :stopwords => ""
                  },
                "1035" => {
                  :name => "Pathway Ontology",
                  :version => "1.032509",
                  :current_ncbo_id => "39665",
                  :stopwords => ""
                  },
                "1000" => {
                  :name => "Mouse adult gross anatomy",
                  :version => "1.194",
                  :current_ncbo_id => "39778",
                  :stopwords => ""
                  },
                "1025" => {
                  :name => "Mammalian Phenotype",
                  :version => "1.250",
                  :current_ncbo_id => "39859",
                  :stopwords => ""
                  },
                "1056" => {
                  :name => "Basic Vertebrate Anatomy",
                  :version => "1.1",
                  :current_ncbo_id => "4531",
                  :stopwords => ""
                  }

#                "39320" => {:name => "Cellular component", :version => "1.429"},
#                "39278" => {:name => "Molecular function", :version => "1.422"},
                }

  STOPWORDS = "I,a,about,an,and,are,as,at,be,by,com,de,en,each,for,from,how,in,is,it,la,of,on,or,that,the,this,to,was,what,when,where,who,will,with,und,the,www,et,al."

  TAG_CLASSES = %w(not-popular not-very-popular somewhat-popular popular very-popular ultra-popular)

  PER_PAGE = 20

  RDF_BIO = "http://bio2rdf.org/"
  RDF_SYNTAX = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  RDF_SCHEMA = "http://www.w3.org/2000/01/rdf-schema"
  RDF_MESH = "http://www.nlm.nih.gov/mesh/2006"
  ELEMENTS = "http://purl.org/dc/elements/1.1/"

end