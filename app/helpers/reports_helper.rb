module ReportsHelper

  def field_name_display(field_name, array)
    if array.include?(field_name)
      "automatic"
    else
      "manual"
    end
  end

  def change_formatted(current, previous, type, manual=false)
    change = ('%.2f' % change_percentage(current, previous, manual))

    if type == "increase"
      positive = "red"
      negative = "green"
    else
      positive = "green"
      negative = "red"
    end

    if change.to_f > 0
      "<span class='change #{positive}'>#{change}%</span>".html_safe
    elsif change.to_f < 0
      "<span class='change #{negative}'>#{change}%</span>".html_safe
    elsif previous.to_f > 0
      "0.0%"
    else
      ""
    end
  end

  def change_percentage(current, previous, manual=false)
    cf = current.to_f
    pf = previous.to_f
    return 0 if (cf == 0 || pf == 0)
    percent_change = manual ? (cf/pf)*100 : ((cf-pf)/cf)*100
  end

  def comparison_date_dropdown(current)
    select_tag(:ddown, options_from_collection_for_select(Comparison.get_all_dates, :archived_at, :archived_at, current))
  end

end
