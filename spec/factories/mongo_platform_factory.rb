# The same, but using a string instead of class constant
Factory.define :mongo_platform, :class => Mongo::Platform do |p|
  p.geo_accession 'GPL1355'
  p.organism  'rat'
  p.title 'Platform Title'
end

