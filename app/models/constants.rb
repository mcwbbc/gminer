class Constants

  MODEL_GEO_PREFIXES = {
                        "Dataset" => "GDS",
                        "Sample" => "GSM",
                        "Platform" => "GPL",
                        "SeriesItem" => "GSE"
                        }
  
  ONTOLOGIES = {
                "13578" => {:name => "NCI Thesaurus", :version => "7.06D"},
                "MSH" => {:name => "Medical Subject Headings, 2009_2008_08_06", :version => "2009_2008_08_06"},
                "39319" => {:name => "Biological process", :version => "1.429"},
                "39320" => {:name => "Cellular component", :version => "1.429"},
                "39278" => {:name => "Molecular function", :version => "1.422"},
                "39234" => {:name => "Rat Strain Ontology", :version => "1.0"},
                "39310" => {:name => "Mouse adult gross anatomy", :version => "1.191"},
                "39071" => {:name => "Mammalian Phenotype", :version => "1.229"},
                "39242" => {:name => "Pathway Ontology", :version => "1.010709"}
                }

  STOPWORDS = "I,a,about,an,and,are,as,at,be,by,com,de,en,each,for,from,how,in,is,it,la,of,on,or,that,the,this,to,was,what,when,where,who,will,with,und,the,www,et,al."

  TAG_CLASSES = %w(not-popular not-very-popular somewhat-popular popular very-popular ultra-popular)

  PER_PAGE = 20

  DATAFILES_PATH = "#{Merb.root}/datafiles"

  RDF_BIO = "http://bio2rdf.org/"
  RDF_SYNTAX = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  RDF_SCHEMA = "http://www.w3.org/2000/01/rdf-schema"
  RDF_MESH = "http://www.nlm.nih.gov/mesh/2006"
  ELEMENTS = "http://purl.org/dc/elements/1.1/"

end