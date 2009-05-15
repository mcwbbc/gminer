module Merb
  module GlobalHelpers
    # helpers defined here available to all views.  

    def login_logout(user)
      if user
        html = link_to("Logout", url(:logout))
        html << ": #{user.email}"
      else
        link_to("Login", url(:login))
      end
    end

    def is_closure(count)
      count > 0 ? count : "is closure"
    end

    def found_count(item_type, items)
      "Number of #{item_type} found: <strong>#{items.total_entries}</strong>"
    end

    def geo_link(geo)
      case geo
      when /^GSM/
        link_to(geo, url(:sample, geo))
      when /^GSE/
        link_to(geo, url(:series_item, geo))
      when /^GPL/
        link_to(geo, url(:platform, geo))
      when /^GDS/
        link_to(geo, url(:dataset, geo))
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

    def all_error_messages_for(*models) 
      errors = []
      for object_name in models
        object = instance_variable_get("@#{object_name.to_s}")
        if object && !object.errors.empty?
          object.errors.full_messages.each { |error| errors << error if !(error =~ /is invalid/)}
        end
      end

      unless errors.empty?
        content_tag("div",
          content_tag("h1", "There are problems with your submission") +
          content_tag("ul", errors.collect { |error| content_tag("li", error) }),
          "id" =>  "errorExplanation", "class" => "errorExplanation"
        )
      end
    end

    def term_link(annotation, fieldname)
      link_to(annotation.ontology_term.name, resource(annotation.ontology_term), :field => fieldname, :class => "annotation-term")
    end

    def ontology_link(annotation)
      link_to(annotation.ontology_term.ontology.name, resource(annotation.ontology_term.ontology))
    end

    def curate_link(annotation, fieldname)
      parameters = {:ontology_term_id => annotation.ontology_term_id, :geo_accession => annotation.geo_accession, :field => annotation.field}
      css = "annotation-term curate unverified"
      if annotation.verified
        css << " verified"
      end
      link_to(annotation.ontology_term.name, url(:curate_annotation, parameters), :field => fieldname, :class => css, :from => annotation.from, :to => annotation.to, :title => "Location: #{annotation.from} - #{annotation.to}")
    end

    def annotation_hash(item, field)
      hash = item.annotations_for(field).inject({}) do |h, a|
        if h.has_key?(a.ontology_term.ontology.name)
          if a.verified?
            if h[a.ontology_term.ontology.name][:terms]
              h[a.ontology_term.ontology.name][:terms] << term_link(a, field)
            else
              h[a.ontology_term.ontology.name][:terms] = [term_link(a, field)]
            end
          end
          h[a.ontology_term.ontology.name][:curate_links] << curate_link(a, field)
        else
          h[a.ontology_term.ontology.name] = {}
          h[a.ontology_term.ontology.name][:link] = ontology_link(a)
          h[a.ontology_term.ontology.name][:terms] = [term_link(a, field)] if a.verified?
          h[a.ontology_term.ontology.name][:curate_links] = [curate_link(a, field)]
        end
        h
      end
    end

    def ontology_array(item, field)
      hash = annotation_hash(item, field)
      ontologies = hash.keys.sort.inject([]) {|a, key| a << {:name => hash[key][:link], :terms => hash[key][:terms] ? hash[key][:terms].join(", ") : "", :curate_links => hash[key][:curate_links].join(" ")}}
    end

    def annotations_for(item, field)
      ontologies = ontology_array(item, field)

      html = '<table width="100%" border="0" cellpadding="0" cellspacing="2">'
      ontologies.each do |ontology|
        html << "#{annotation_partial(field, ontology[:name], ontology[:terms], ontology[:curate_links])}"
      end
      html << "</table>"
      html
    end

    def annotation_partial(field, ontology_name, term_list, curate_link_list)
      partial("shared/annotation", {:fieldname => field, :ontology_name => ontology_name, :term_list => term_list, :curate_link_list => curate_link_list})
    end

    def page_title(title)
      "<div class='page-title'>#{title}</div>"
    end

    def flash_message(hash)
      html = ""
      hash.each_key do |css|
        message = hash[css]
        html << "<div class='#{css}'>#{message}</div>"
      end
      html
    end

    # Create as many of these as you like, each should call a different partial 
      # 1. Render 'shared/rounded_box' partial with the given options and block content
    def rounded_box(css_class, options = {}, &block)
      throw_content(:for_box, capture(&block))
      partial('shared/rounded_box', options.merge(:css_class => css_class))
    end

  end
end
