module TagsHelper

  def tagged_items(tag)
    tag.taggings.inject([]) do |array, tagging|
      array << geo_link(tagging.taggable.geo_accession)
      array
    end.join(", ")
  end

end
