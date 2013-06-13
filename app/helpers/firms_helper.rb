module FirmsHelper

	def number_shift_requests
		@shift_requests_number = 0
		@firm = Firm.find(params[:id])
		@shifts = Shift.find_all_by_firm_id_and_fk_user_worker(@firm.id,nil)
		@shifts.each do |shift|
			@shift_requests_number += shift.shift_requests.all.count
			return @shift_requests_number
		end
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

end
