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
                  :stopwords => "AL,AK,AZ,AR,CA,CO,CT,DE,DC,FL,GA,HI,ID,IL,IN,IA,KS,KY,LA,ME,MD,MA,MI,MN,MS,MO,MT,NV,NH,NJ,NM,NY,NC,ND,OH,OK,OR,PA,RI,SC,TN,TX,UT,VT,VA,WA,WV,WI,WY"
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

  STOPWORDS = "a,about,above,across,after,again,against,all,almost,alone,along,already,also,although,always,among,an,and,another,any,anybody,anyone,anything,anywhere,are,area,areas,around,as,ask,asked,asking,asks,at,away,b,back,backed,backing,backs,be,became,because,become,becomes,been,before,began,behind,being,beings,best,better,between,big,both,but,by,c,came,can,cannot,case,cases,certain,certainly,clear,clearly,come,could,d,did,differ,different,differently,do,does,done,down,down,downed,downing,downs,during,e,each,early,either,end,ended,ending,ends,enough,even,evenly,ever,every,everybody,everyone,everything,everywhere,f,face,faces,fact,facts,far,felt,few,find,finds,first,for,four,from,full,fully,further,furthered,furthering,furthers,g,gave,general,generally,get,gets,give,given,gives,go,going,good,goods,got,great,greater,greatest,group,grouped,grouping,groups,h,had,has,have,having,he,her,here,herself,high,high,high,higher,highest,him,himself,his,how,however,i,if,important,in,interest,interested,interesting,interests,into,is,it,its,itself,j,just,k,keep,keeps,kind,knew,know,known,knows,l,large,largely,last,later,latest,least,less,let,lets,like,likely,long,longer,longest,m,made,make,making,man,many,may,me,member,members,men,might,more,most,mostly,mr,mrs,much,must,my,myself,n,necessary,need,needed,needing,needs,never,new,new,newer,newest,next,no,nobody,non,noone,not,nothing,now,nowhere,number,numbers,o,of,off,often,old,older,oldest,on,once,one,only,open,opened,opening,opens,or,order,ordered,ordering,orders,other,others,our,out,over,p,part,parted,parting,parts,per,perhaps,place,places,point,pointed,pointing,points,possible,present,presented,presenting,presents,problem,problems,put,puts,q,quite,r,rather,really,right,right,room,rooms,s,said,same,saw,say,says,second,seconds,see,seem,seemed,seeming,seems,sees,several,shall,she,should,show,showed,showing,shows,side,sides,since,small,smaller,smallest,so,some,somebody,someone,something,somewhere,state,states,still,still,such,sure,t,take,taken,than,that,the,their,them,then,there,therefore,these,they,thing,things,think,thinks,this,those,though,thought,thoughts,three,through,thus,to,today,together,too,took,toward,turn,turned,turning,turns,two,u,under,until,up,upon,us,use,used,uses,v,very,w,want,wanted,wanting,wants,was,way,ways,we,well,wells,went,were,what,when,where,whether,which,while,who,whole,whose,why,will,with,within,without,work,worked,working,works,would,x,y,year,years,yet,you,young,younger,youngest,your,yours,z,et,al."

  TAG_CLASSES = %w(not-popular not-very-popular somewhat-popular popular very-popular ultra-popular)

  PER_PAGE = 15

  RDF_BIO = "http://bio2rdf.org/"
  RDF_SYNTAX = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  RDF_SCHEMA = "http://www.w3.org/2000/01/rdf-schema"
  RDF_MESH = "http://www.nlm.nih.gov/mesh/2006"
  ELEMENTS = "http://purl.org/dc/elements/1.1/"

end