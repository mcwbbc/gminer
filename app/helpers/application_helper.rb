# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  include TagsHelper

  FLASH_NOTICE_KEYS = [:success, :notice, :warning, :failure, :invalid, :alert, :unauthenticated, :unconfirmed, :invalid_token, :timeout, :inactive, :locked]

  def signin_signout
    if user_signed_in?
      link_to(t('link.dashboard'), user_url(current_user))+" - "+link_to(t('link.sign-out'), destroy_user_session_url, :confirm => t('confirm.areyousure'))
    else
      content_tag(:div, link_to(t('link.sign-in'), new_user_session_url)+" - "+link_to(t('link.sign-up'), new_registration_url(User)), :class => 'login-box')
    end
  end

  def flash_messages
    return unless messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k)}
    formatted_messages = messages.map do |type|
      content_tag(:div, :class => type.to_s) do
        message_for_item(flash[type], flash["#{type}_item".to_sym])
      end
    end
    flash.clear
    formatted_messages.join
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message % item
    end
  end

  def error_messages_for(resource)
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = "#{pluralize(resource.errors.count, "error")} prohibited this #{resource.class.name.downcase} from being saved:"

    html = content_tag(:div, :class => 'error_explanation') do
      content_tag(:h2, sentence)+content_tag(:ul, messages.html_safe)
    end
    html.html_safe
  end

  def page_title(title)
    content_tag(:div, title, :class => 'page-title')
  end

  def term_cloud(terms, classes)
    if terms && terms.any?
      max, min = 0, terms[0].annotations_count.to_i
      terms.each { |t|
        max = t.annotations_count.to_i if t.annotations_count.to_i > max
        min = t.annotations_count.to_i if t.annotations_count.to_i < min
      }

      divisor = ((max - min) / classes.size) + 1

      terms.each { |t|
        yield t, classes[(t.annotations_count.to_i - min) / divisor]
      }
    end
  end

  def has_annotations(count)
    count > 0 ? count : "No annotations"
  end

  def formatted_percent(count, total)
    percent = (count.to_f/total.to_f)*100
    "#{'%.2f' % percent}%"
  end

  def annotation_percentage(count, percent)
    count > 0 ? "#{'%.2f' % percent}%" : "No annotations"
  end

  def found_count(item_type, items)
    if !item_type.is_a?(Array)
      "Number of #{item_type} found: <strong>#{items.total_entries}</strong>".html_safe
    end
  end

  def ncbi_link(geo_accession)
    link_to("NCBI: #{geo_accession}", "http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=#{geo_accession}&targ=self&form=html&view=quick", :target => "_blank", :class => "ncbolink")
  end

  def pubmed_link(pubmed_id)
    if pubmed_id.blank?
      ""
    else
      links = pubmed_id.split(' ').inject([]) do |a, id|
        a << link_to("#{id}", "http://www.ncbi.nlm.nih.gov/sites/entrez?Db=Pubmed&term=#{id}[UID]", :target => "_blank", :class => "pubmedlink")
        a
      end
      links.join(', ').html_safe
    end
  end

  def term_css(annotation, seed_css)
    css = seed_css
    if annotation.created_by_id == 0
      css << " automatic-annotation"
    else
      css << " manual-annotation"
    end

    if !annotation.audited?
      css << " unaudited"
    elsif annotation.verified?
      css << " verified"
      css << " predicate-#{annotation.predicate}"
    else
      css << " unverified"
    end
    css
  end

  def term_div(annotation)
    css = term_css(annotation, "annotation-term")

    link_div = content_tag(:div, :class => "term-div #{css}") do
      annotation.ontology_term.name
    end
  end

  def term_link(annotation)
    css = term_css(annotation, "cyto")

    link_div = content_tag(:div, :class => 'term-ncbo-link') do
      link = link_to(annotation.ontology_term.name, ontology_term_url(annotation.ontology_term), :ontology_term_id => annotation.resource_id, :field_name => annotation.field_name, :class => css)
      link << ncbo_ontology_link(annotation.ontology_term)
      link
    end
  end

  def ontology_link(annotation)
    link_to(annotation.ontology_term.ontology.name, ontology_url(annotation.ontology_term.ontology))
  end

  def geo_link(geo, new_window=false)
    case geo
      when /^GSM/
        link_to(geo, sample_url(geo), :target => new_window ? "_blank" : "" )
      when /^GSE/
        link_to(geo, series_item_url(geo), :target => new_window ? "_blank" : "" )
      when /^GPL/
        link_to(geo, platform_url(geo), :target => new_window ? "_blank" : "" )
      when /^GDS/
        link_to(geo, dataset_url(geo), :target => new_window ? "_blank" : "" )
      else
        geo
    end
  end

  def highlight(text, phrases)
    options = {:highlighter => '<strong class="highlight">\1</strong>'}
    if text.blank? || phrases.blank?
      text.html_safe
    else
      match = Array(phrases).map { |p| Regexp.escape(p) }.join('|')
      text.gsub(/(#{match})(?!(?:[^<]*?)?(?:["'])[^<>]*>)/i, options[:highlighter]).html_safe
    end
  end

  def curate_link(annotation)
    parameters = {:ontology_term_id => annotation.ontology_term_id, :geo_accession => annotation.geo_accession, :field_name => annotation.field_name}
    css = term_css(annotation, "annotation-term curate cyto")

    link_div = content_tag(:div, :class => 'term-ncbo-link') do
      link = link_to(annotation.ontology_term.name, curate_annotation_url(annotation), :ontology_term_id => annotation.resource_id, :ontology_term => annotation.ontology_term.term_id, :id => "link-#{annotation.id}", :field_name => annotation.field_name, :class => css, :from => annotation.from, :to => annotation.to, :text => annotation.ontology_term.name, :title => "Location: #{annotation.from} - #{annotation.to}")
      link << ncbo_ontology_link(annotation.ontology_term)
      link
    end
  end

  def ncbo_ontology_link(ontology_term)
    ncbo_id, term_id = ontology_term.term_id.split("|")
    alt = "Visualize #{term_id} at NCBO Bioportal"
    link_to(image_tag("icons/ncbo_bioportal.png", :alt => alt), "http://bioportal.bioontology.org/virtual/#{ontology_term.ontology.ncbo_id}/#{term_id}", :target => "_blank", :title => alt)
  end

  def annotation_hash(item, field_name)
    hash = item.annotations_for(field_name).inject({}) do |h, a|
      if h.has_key?(a.ontology_term.ontology.name)
        if h[a.ontology_term.ontology.name][:terms]
          h[a.ontology_term.ontology.name][:terms] << term_link(a)
        else
          h[a.ontology_term.ontology.name][:terms] = [term_link(a)]
        end
        h[a.ontology_term.ontology.name][:curate_links] << curate_link(a)
      else
        h[a.ontology_term.ontology.name] = {}
        h[a.ontology_term.ontology.name][:link] = ontology_link(a)
        h[a.ontology_term.ontology.name][:terms] = [term_link(a)]
        h[a.ontology_term.ontology.name][:curate_links] = [curate_link(a)]
      end
      h
    end
  end

  def ontology_array(item, field_name)
    hash = annotation_hash(item, field_name)
    ontologies = hash.keys.sort.inject([]) {|a, key| a << {:name => hash[key][:link], :terms => hash[key][:terms] ? hash[key][:terms].join("") : "", :curate_links => hash[key][:curate_links].join("")}}
  end

  def annotations_for(item, field_name)
    ontologies = ontology_array(item, field_name)

    html = '<table width="100%" border="0" cellpadding="0" cellspacing="2">'
    ontologies.each do |ontology|
      html << "#{annotation_partial(field_name, ontology[:name], ontology[:terms], ontology[:curate_links])}"
    end
    html << "</table>"
    html.html_safe
  end

  def annotation_partial(field_name, ontology_name, term_list, curate_link_list)
    render(:partial => "shared/annotation", :locals => {:field_name => field_name, :ontology_name => ontology_name, :term_list => term_list, :curate_link_list => curate_link_list})
  end

end
