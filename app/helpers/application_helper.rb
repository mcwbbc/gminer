# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  FLASH_NOTICE_KEYS = [:success, :notice, :warning]

  def flash_messages
    return unless messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k)}
    formatted_messages = messages.map do |type|
      content_tag :div, :class => type.to_s do
        message_for_item(flash[type], flash["#{type}_item".to_sym])
      end
    end
    flash.clear
    formatted_messages.join
  end

  def render_errors(item, header=false)
    unless header
      render(:partial => 'shared/form_errors', :locals => { :record => item }) if item
    else
      render(:partial => 'shared/form_error_header', :locals => { :record => item }) if item
    end
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message % item
    end
  end

  # Only need this helper once, it will provide an interface to convert a block into a partial.
    # 1. Capture is a Rails helper which will 'capture' the output of a block into a variable
    # 2. Merge the 'body' variable into our options hash
    # 3. Render the partial with the given options hash. Just like calling the partial directly.
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options))
  end

  # Create as many of these as you like, each should call a different partial
    # 1. Render 'shared/rounded_box' partial with the given options and block content
  def rounded_box(css_class, options = {}, &block)
    block_to_partial('shared/rounded_box', options.merge(:css_class => css_class), &block)
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

  def page_title(title)
    "<div class='page-title'>#{title}</div>"
  end

  def signin_signout
    if logged_in?
      link_to(t('link.user'), account_path)+"<br />"+link_to(t('link.signout'), user_session_path, :method => :delete, :confirm => t('confirm.signout'))
    else
      link_to(t('link.signin'), new_user_session_path)+" - "+link_to(t('link.signup'), new_account_path)
    end
  end

  def is_closure(count)
    count > 0 ? count : "is closure"
  end

  def formatted_percent(count, total)
    percent = (count.to_f/total.to_f)*100
    "#{'%.2f' % percent}%"
  end

  def annotation_percentage(count, percent)
    count > 0 ? "#{'%.2f' % percent}%" : "is closure"
  end

  def found_count(item_type, items)
    "Number of #{item_type} found: <strong>#{items.total_entries}</strong>"
  end

  def ncbi_link(geo_accession)
    link_to("NCBI: #{geo_accession}", "http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=#{geo_accession}&targ=self&form=html&view=quick", :target => "_blank", :class => "ncbolink")
  end

  def pubmed_link(pubmed_id)
    if pubmed_id.blank?
      ""
    else
      link_to("#{pubmed_id}", "http://www.ncbi.nlm.nih.gov/sites/entrez?Db=Pubmed&term=#{pubmed_id}[UID]", :target => "_blank", :class => "pubmedlink")
    end
  end

  def term_link(annotation)
    if !annotation.audited?
      css = "unaudited"
    elsif annotation.verified?
      css = "verified"
    else
      css = "unverified"
    end

    if annotation.user_id == 0
      css << " automatic-annotation"
    else
      css << " manual-annotation"
    end

    link_to(annotation.ontology_term.name, ontology_term_url(annotation.ontology_term), :field => annotation.field, :class => css)
  end

  def ontology_link(annotation)
    link_to(annotation.ontology_term.ontology.name, ontology_url(annotation.ontology_term.ontology))
  end

  def ncbo_ontology_link(ontology_term)
    ncbo_id, term_id = ontology_term.term_id.split("|")
    alt = "Visualize #{term_id} at NCBO Bioportal"
    link_to(image_tag("icons/ncbo_bioportal.png", :alt => alt), "http://bioportal.bioontology.org/virtual/#{ontology_term.ontology.ncbo_id}/#{term_id}", :target => "_blank", :title => alt)
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
      text
    else
      match = Array(phrases).map { |p| Regexp.escape(p) }.join('|')
      text.gsub(/(#{match})(?!(?:[^<]*?)?(?:["'])[^<>]*>)/i, options[:highlighter])
    end
  end

  def curate_link(annotation)
    parameters = {:ontology_term_id => annotation.ontology_term_id, :geo_accession => annotation.geo_accession, :field => annotation.field}
    css = "annotation-term curate"

    if annotation.user_id == 0
      css << " automatic-annotation"
    else
      css << " manual-annotation"
    end

    if !annotation.audited?
      css << " unaudited"
    elsif annotation.verified?
      css << " verified"
    else
      css << " unverified"
    end

    link_to(annotation.ontology_term.name, curate_annotation_url(annotation), :id => "link-#{annotation.id}", :field => annotation.field, :class => css, :from => annotation.from, :to => annotation.to, :title => "Location: #{annotation.from} - #{annotation.to}")
  end

  def annotation_hash(item, field)
    hash = item.annotations_for(field).inject({}) do |h, a|
      if h.has_key?(a.ontology_term.ontology.name)
        if h[a.ontology_term.ontology.name][:terms]
          h[a.ontology_term.ontology.name][:terms] << term_link(a)
        else
          h[a.ontology_term.ontology.name][:terms] = [term_link(a)]
        end
        h[a.ontology_term.ontology.name][:curate_links] << curate_link(a)
        h[a.ontology_term.ontology.name][:ncbo_ontology_links] << ncbo_ontology_link(a.ontology_term)
      else
        h[a.ontology_term.ontology.name] = {}
        h[a.ontology_term.ontology.name][:link] = ontology_link(a)
        h[a.ontology_term.ontology.name][:terms] = [term_link(a)]
        h[a.ontology_term.ontology.name][:curate_links] = [curate_link(a)]
        h[a.ontology_term.ontology.name][:ncbo_ontology_links] = [ncbo_ontology_link(a.ontology_term)]
      end
      h
    end
  end

  def ontology_array(item, field)
    hash = annotation_hash(item, field)
    ontologies = hash.keys.sort.inject([]) {|a, key| a << {:name => hash[key][:link], :terms => hash[key][:terms] ? hash[key][:terms].join("") : "", :curate_links => hash[key][:curate_links].join(""), :ncbo_ontology_links => hash[key][:ncbo_ontology_links].join("")}}
  end

  def annotations_for(item, field)
    ontologies = ontology_array(item, field)

    html = '<table width="100%" border="0" cellpadding="0" cellspacing="2">'
    ontologies.each do |ontology|
      html << "#{annotation_partial(field, ontology[:name], ontology[:terms], ontology[:curate_links], ontology[:ncbo_ontology_links])}"
    end
    html << "</table>"
    html
  end

  def annotation_partial(field, ontology_name, term_list, curate_link_list, ncbo_ontology_link_list)
    render(:partial => "shared/annotation", :locals => {:fieldname => field, :ontology_name => ontology_name, :term_list => term_list, :curate_link_list => curate_link_list, :ncbo_ontology_link_list => ncbo_ontology_link_list})
  end

  # Block method that creates an area of the view that
  # is only rendered if the request is coming from an
  # anonymous user.
  def anonymous_only(&block)
    if !logged_in?
      block.call
    end
  end

  # Block method that creates an area of the view that
  # only renders if the request is coming from an
  # authenticated user.
  def authenticated_only(&block)
    if logged_in?
      block.call
    end
  end

  # Block method that creates an area of the view that
  # only renders if the request is coming from an
  # administrative user.
  def admin_only(&block)
    role_only("admin", &block)
  end

  def state_options
    I18n.t('states').collect{|abbrev, full_name| [full_name.to_s, abbrev.to_s]}.sort{|a,b| a.first <=> b.first}
  end

  def state_options_with_blank(label = "")
    state_options.unshift([label, ""])
  end

  def full_state_name(state_abbrev)
    state_options.each do |full_name, abbrev|
      return full_name if abbrev == state_abbrev
    end
    nil
  end

private

  def admin_user?
    not current_user.blank? and current_user.has_role?("admin")
  end

  def role_only(rolename, &block)
    if admin_user?
      block.call
    end
  end

end

