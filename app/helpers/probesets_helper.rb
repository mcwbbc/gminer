module ProbesetsHelper

  def probeset_platform_links(platforms)
    platforms.map {|platform| "#{geo_link(platform.geo_accession)} - #{platform.title}"}.join("<br />")
  end

end
