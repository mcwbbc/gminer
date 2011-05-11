class Constants

  DETECTION_STATUSES = ['P', 'A', 'M']

  MODEL_GEO_PREFIXES = {
                        "Dataset" => "GDS",
                        "Sample" => "GSM",
                        "Gminer::Platform" => "GPL",
                        "Platform" => "GPL",
                        "SeriesItem" => "GSE"
                        }

  GEO_TYPES = ["Dataset", "Platform", "Sample", "Series"]

  RESOURCE_INDEX = {"SMD"=>"Stanford Microarray Database",
               "GAP"=>"Database of Genotypes and Phenotypes",
               "MICAD"=>"MICAD",
               "AE"=>"ArrayExpress",
               "AERS"=>"Adverse Event Reporting System Data",
               "WP"=>"WikiPathways",
               "PGGE"=>"PharmGKB [Gene]",
               "GEO"=>"Gene Expression Omnibus DataSets",
               "OMIM"=>"Online Mendelian Inheritance in Man",
               "DBK"=>"DrugBank",
               "PGDR"=>"PharmGKB [Drug]",
               "PC"=>"Pathway Commons",
               "CDD"=>"Conserved Domain Database (CDD)",
               "PCM"=>"PubChem",
               "UPKB"=>"UniProt KB",
               "CT"=>"ClinicalTrials.gov",
               "CANANO"=>"caNanoLab",
               "REAC"=>"Reactome",
               "PGDI"=>"PharmGKB [Disease]",
               "GM"=>"ARRS GoldMiner",
               "RXRD"=>"ResearchCrossroads",
               "BSM"=>"Biositemaps"}

  ONTOLOGIES = {
                "all" => {
                  :name => "All ontology",
                  :version => "",
                  :current_ncbo_id => "",
                  :stopwords => "",
                  :expand_ontologies => ""
                  },
                "1032" => {
                  :name => "NCI Thesaurus",
                  :version => "10.03",
                  :current_ncbo_id => "42838",
                  :stopwords => "",
                  :expand_ontologies => ""
                  },
                "1351" => {
                  :name => "Medical Subject Headings",
                  :version => "2011_2010_08_30",
                  :current_ncbo_id => "44776",
                  :stopwords => "",
                  :expand_ontologies => ""
                  },
                "1070" => {
                  :name => "Gene Ontology",
                  :version => "1.1102",
                  :current_ncbo_id => "45118",
                  :stopwords => "",
                  :expand_ontologies => ""
                  },
                "1150" => {
                  :name => "Rat Strain Ontology",
                  :version => "2.2",
                  :current_ncbo_id => "45010",
                  :stopwords => "AL,AK,AZ,AR,CA,CO,CT,DE,DC,FL,GA,HI,ID,IL,IN,IA,KS,KY,LA,ME,MD,MA,MI,MN,MS,MO,MT,NV,NH,NJ,NM,NY,NC,ND,OH,OK,OR,PA,RI,SC,TN,TX,UT,VT,VA,WA,WV,WI,WY,rat strain",
                  :expand_ontologies => "1150"
                  },
                "1035" => {
                  :name => "Pathway Ontology",
                  :version => "1.060710",
                  :current_ncbo_id => "42912",
                  :stopwords => "",
                  :expand_ontologies => ""
                  },
                "1000" => {
                  :name => "Mouse adult gross anatomy",
                  :version => "1.207",
                  :current_ncbo_id => "45065",
                  :stopwords => "male,cell",
                  :expand_ontologies => ""
                  },
                "1025" => {
                  :name => "Mammalian Phenotype",
                  :version => "1.407",
                  :current_ncbo_id => "45091",
                  :stopwords => "",
                  :expand_ontologies => ""
                  },
                "1056" => {
                  :name => "Basic Vertebrate Anatomy",
                  :version => "1.1",
                  :current_ncbo_id => "4531",
                  :stopwords => "",
                  :expand_ontologies => ""
                  },
                "1006" => {
                  :name => "Cell type",
                  :version => "1.48",
                  :current_ncbo_id => "45024",
                  :stopwords => "cell,bundle",
                  :expand_ontologies => ""
                  }

#                "39320" => {:name => "Cellular component", :version => "1.429"},
#                "39278" => {:name => "Molecular function", :version => "1.422"},
                }

  STOPWORDS = "a,about,above,across,after,again,against,all,almost,alone,along,already,also,although,always,among,an,and,another,any,anybody,anyone,anything,anywhere,are,area,areas,around,as,ask,asked,asking,asks,at,away,b,back,backed,backing,backs,be,became,because,become,becomes,been,before,began,behind,being,beings,best,better,between,big,both,but,by,c,came,can,cannot,case,cases,certain,certainly,clear,clearly,come,could,d,did,differ,different,differently,do,does,done,down,down,downed,downing,downs,during,e,each,early,either,end,ended,ending,ends,enough,even,evenly,ever,every,everybody,everyone,everything,everywhere,f,face,faces,fact,facts,far,felt,few,find,finds,first,for,four,from,full,fully,further,furthered,furthering,furthers,g,gave,general,generally,get,gets,give,given,gives,go,going,good,goods,got,great,greater,greatest,group,grouped,grouping,groups,h,had,has,have,having,he,her,here,herself,high,high,high,higher,highest,him,himself,his,how,however,i,if,important,in,interest,interested,interesting,interests,into,is,it,its,itself,j,just,k,keep,keeps,kind,knew,know,known,knows,l,large,largely,last,later,latest,least,less,let,lets,like,likely,long,longer,longest,m,made,make,making,man,many,may,me,member,members,men,might,more,most,mostly,mr,mrs,much,must,my,myself,n,necessary,need,needed,needing,needs,never,new,new,newer,newest,next,no,nobody,non,noone,not,nothing,now,nowhere,number,numbers,o,of,off,often,old,older,oldest,on,once,one,only,open,opened,opening,opens,or,order,ordered,ordering,orders,other,others,our,out,over,p,part,parted,parting,parts,per,perhaps,place,places,point,pointed,pointing,points,possible,present,presented,presenting,presents,problem,problems,put,puts,q,quite,r,rather,really,right,right,room,rooms,s,said,same,saw,say,says,second,seconds,see,seem,seemed,seeming,seems,sees,several,shall,she,should,show,showed,showing,shows,side,sides,since,small,smaller,smallest,so,some,somebody,someone,something,somewhere,state,states,still,still,such,sure,t,take,taken,than,that,the,their,them,then,there,therefore,these,they,thing,things,think,thinks,this,those,though,thought,thoughts,three,through,thus,to,today,together,too,took,toward,turn,turned,turning,turns,two,u,under,until,up,upon,us,use,used,uses,v,very,w,want,wanted,wanting,wants,was,way,ways,we,well,wells,went,were,what,when,where,whether,which,while,who,whole,whose,why,will,with,within,without,work,worked,working,works,would,x,y,year,years,yet,you,young,younger,youngest,your,yours,z,et,al."

  TAG_CLASSES = %w(not-popular not-very-popular somewhat-popular slightly-popular popular very-popular ultra-popular mega-popular)

  PER_PAGE = 15

  RDF_BIO = "http://bio2rdf.org/"
  RDF_SYNTAX = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  RDF_SCHEMA = "http://www.w3.org/2000/01/rdf-schema"
  RDF_MESH = "http://www.nlm.nih.gov/mesh/2006"
  ELEMENTS = "http://purl.org/dc/elements/1.1/"

  GEO_ACCESSION_IDS = {
                        "Dataset" => Dataset.load_dataset,
                        "Sample" => Sample.load_sample,
                        "Gminer::Platform" => Gminer::Platform.load_platform,
                        "Platform" => Gminer::Platform.load_platform,
                        "SeriesItem" => SeriesItem.load_series_items
                        }

end