module ApplicationHelper

	  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Test App generic title"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def short_date(datetime)
  	weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  	month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  	return "#{weekday[datetime.wday]} #{datetime.day} #{month[datetime.month]}"
  end


end
