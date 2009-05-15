class Detection
  include DataMapper::Resource
  
  property :sample_geo_accession, String, :length => 25, :key => true
  property :id_ref, String, :length => 100, :key => true
  property :abs_call, String, :length => 2, :key => true

  def present?
    self.abs_call == "P"
  end

end
