module ApplicationHelper

	  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Shift Cloud"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def short_date(datetime)
  	weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  	month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  	return "#{weekday[datetime.wday]} #{datetime.day} #{month[datetime.month - 1]}"
  end

  def shift_start_div_width(shift, daystarthour, daylength)
    @shift_start_hour = [shift.start_datetime, @s_date.beginning_of_day].sort.last.seconds_since_midnight.to_i
    @ss_width = (@shift_start_hour.to_f - daystarthour.to_f) / daylength.to_f * 98
    return @ss_width
  end

  def shift_body_div_width(shift, daylength)
    @shift_start_hour = [shift.start_datetime, @s_date.beginning_of_day].sort.last.seconds_since_midnight.to_i
    @shift_end_hour = [shift.end_datetime, @s_date.end_of_day].sort.first.seconds_since_midnight.to_i
    @shift_length = @shift_end_hour - @shift_start_hour
    return @shift_length.to_f / daylength.to_f * 98
  end



end
