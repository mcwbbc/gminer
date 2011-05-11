module ProbesetsHelper

  def probeset_platform_links(platforms)
    if platforms.any?
      platforms.map {|platform| "#{geo_link(platform.geo_accession)} - #{platform.title}"}.join("<br />").html_safe
    else
      "No mapping"
    end
  end

  def probeset_rgd_gene_link(rgd_gene)
    if !rgd_gene.blank?
      link_to(rgd_gene, "http://rgd.mcw.edu/tools/genes/genes_view.cgi?id=#{rgd_gene}", :target => '_blank')
    else
      "No mapping"
    end
  end

  def probeset_symbol(symbol)
    if !symbol.blank?
      symbol
    else
      "No mapping"
    end
  end

  def associated_probeset_links(probeset)
    probeset_links = []
    probeset.associated_probesets.each do |associated_probeset|
      probeset_links << link_to(associated_probeset.name, probeset_url(associated_probeset))
    end
    if probeset_links.any?
      probeset_links.join(", ")
    else
      "No mapping"
    end
  end

end

