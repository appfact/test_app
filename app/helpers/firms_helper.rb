module FirmsHelper

	def number_shift_requests
		@firm = Firm.find(current_user.business_id)
		@shift_requests_number = @firm.shift_requests
                                .where(:worker_status => true, :manager_status => nil) 
                                .where('start_datetime > ? AND fk_user_worker is ?', Time.now.to_datetime, nil)
                                .order(:shift_id, :created_at).length

        return @shift_requests_number
	end

	def open_shift_requests_array
		@firm = Firm.find(params[:id])
		@shifts_requested = []
		@shifts = Shift.find_all_by_firm_id_and_fk_user_worker(@firm.id,nil)
		@shifts.each do |shift|
			@shiftdetails = shift.shift_requests.find_all_by_worker_status_and_manager_status(true,nil)
			if !@shiftdetails.empty?
				@shifts_requested.push(@shiftdetails)
				@shiftdetails = []
			end
		end
		return @shifts_requested
	end

	def span_array_method(starthour,endhour)
		(endhour - starthour < 1) ? @span_length = 1 : @span_length = endhour - starthour
		@span_intervals_array = [[0],[0,1],[0,1,2],[0,1,2,3],[0,2,4],[0,2,4],[0,2,4,6],[0,2,4,6],
									[0,4,8],[0,3,6,9],[0,5,10],[0,5,10],[0,4,8,12],[0,4,8,12],[0,4,8,12],
									[0,5,10,15],[0,5,10,15],[0,5,10,15],[0,6,12,18],[0,6,12,18],[0,6,12,18],
									[0,7,14,21],[0,7,14,21],[0,7,14,21],[0,8,16,24]]
		@span_intervals = @span_intervals_array[@span_length]
		@span_intervals.map!{|interval| interval + starthour}
		return (@span_intervals.join(':00 ') + ":00").to_s
	end

	def employee_shifts_number(employee, from, to)
		 return Shift.where(fk_user_worker: employee.id).
		 			where('start_datetime >= ? AND start_datetime <= ?',from.beginning_of_day, to.end_of_day).length
	end

	def employee_shifts_hours(employee, from, to)
		@shifts_array = Shift.where(fk_user_worker: employee.id).
		 			where('start_datetime >= ? AND start_datetime <= ?',from.beginning_of_day, to.end_of_day)
		@hours = 0
		@shifts_array.each do |shift|
			@hours += (shift.end_datetime - shift.start_datetime)
		end
		return "#{(@hours.to_i - @hours.to_i % 3600)/3600} hours #{(@hours.to_i % 3600)/60} minutes"
	end

end
