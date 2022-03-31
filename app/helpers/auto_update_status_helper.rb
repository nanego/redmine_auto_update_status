module AutoUpdateStatusHelper

  def final_priority_value(final_priority)
    return "" if final_priority.blank?
    if final_priority.to_i.to_s == final_priority
      IssuePriority.find(final_priority).name
    else
      l("label_#{final_priority}_priority")
    end
  end

end
