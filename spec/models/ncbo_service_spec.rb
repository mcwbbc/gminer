require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe NCBOService do

  describe "current_ncbo_id" do
    it "should return an array of id, name, version" do
      NCBOService.should_receive(:get).with("/bioportal/virtual/ontology/1000").and_return(ONTOLOGY_ID_HASH)
      NCBOService.current_ncbo_id(1000).should == ["39778", "Mouse adult gross anatomy", "1.194"]
    end

    it "should raise an exception on failure" do
      NCBOService.should_receive(:get).with("/bioportal/virtual/ontology/1000").and_return({})
      lambda {NCBOService.current_ncbo_id(1000)}.should raise_error(NCBOException)
    end
  end

end

ONTOLOGY_ID_HASH = {"success"=>
  {"data"=>
    {"ontologyBean"=>
      {"contactName"=>"Anatomy JAX",
       "isFoundry"=>"1",
       "hasViews"=>nil,
       "format"=>"OBO",
       "filenames"=>{"string"=>"adult_mouse_anatomy.obo"},
       "dateReleased"=>"2009-04-12 02:32:33.0 PDT",
       "viewOnOntologyVersionId"=>nil,
       "versionStatus"=>"production",
       "groupIds"=>{"int"=>"6001"},
       "filePath"=>"/1000/9",
       "codingScheme"=>
        "http://www.bioontology.org/39778/Mouse adult gross anatomy|1000/9",
       "categoryIds"=>{"int"=>["2812", "2811", "2810", "2817"]},
       "id"=>"39778",
       "versionNumber"=>"1.194",
       "isRemote"=>"0",
       "abbreviation"=>"MA",
       "userId"=>"38116",
       "statusId"=>"3",
       "isView"=>"false",
       "isManual"=>"0",
       "homepage"=>"http://www.informatics.jax.org/searches/AMA_form.shtml",
       "internalVersionNumber"=>"9",
       "dateCreated"=>"2009-04-12 02:32:33.0 PDT",
       "oboFoundryId"=>"adult_mouse_anatomy",
       "description"=>
        "A structured controlled vocabulary of the adult anatomy of the mouse (Mus).",
       "contactEmail"=>"anatomy@informatics.jax.org",
       "displayLabel"=>"Mouse adult gross anatomy",
       "ontologyId"=>"1000",
       "virtualViewIds"=>nil}},
   "accessDate"=>"2009-10-02 12:49:41.718 PDT",
   "accessedResource"=>"/bioportal/virtual/ontology/1000"}}
