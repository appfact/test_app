module ShiftRequestsHelper

	def request_complete?(requestid)
		@request = Shift_request.find(requestid)
		if (@request.manager_status && @request.worker_status)
			true
		else
			false
		end
	end

end
