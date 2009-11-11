module JobsHelper

  def job_status_dropdown(current)
    select_tag(:status, options_for_select(["Pending", "Active", "Finished"], current))
  end

  def date_or_pending(date)
    date ? Time.at(date).to_s(:us_with_time) : "Pending"
  end

end
