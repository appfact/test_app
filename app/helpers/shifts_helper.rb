module ShiftsHelper

	def shift_filled?(shiftid)
		!Shift.find(shiftid).fk_user_worker.nil? ? true : false
	end

	def can_delete_shift(shiftx)
		(current_user.admin? && current_user.business_id == shiftx.firm_id) ? true : false
		# might want to change this to be permissions instead of current_user.business.id
		
	end

	def shift_number_of_offers(shiftx)
		return shiftx.shift_requests.where(manager_status: true).where(worker_status: nil).length
	end

	def shift_number_of_requests(shiftx)
		return shiftx.shift_requests.where(worker_status: true).where(manager_status: nil).length
	end

	def shifts_prev_7d(userx)
		return Shift.where('start_datetime <= ? AND start_datetime > ? AND fk_user_worker = ?', 
			Time.now.to_datetime, Time.now - 7.days, userx.id).length
	end

	def shifts_next_7d(userx)
		return Shift.where('start_datetime >= ? AND start_datetime < ? AND fk_user_worker = ?', 
			Time.now.to_datetime, Time.now + 7.days, userx.id).length
	end

	def shifts_total(userx)
		return Shift.where('end_datetime < ? AND fk_user_worker = ?', Time.now.to_datetime, userx.id).length
	end

	def user_available?(shiftx, userx)
		if userx.shifts.where('(start_datetime >= ? AND start_datetime <= ?) OR (end_datetime >= ? AND end_datetime <= ?)',
						shiftx.start_datetime, shiftx.end_datetime, shiftx.start_datetime, shiftx.end_datetime).any?
			return false
		else
			return true
		end
	end

	def user_available(shiftx, userx)
		if Shift.where('(fk_user_worker = ? AND start_datetime >= ? AND start_datetime <= ?) 
						OR (fk_user_worker = ? AND end_datetime >= ? AND end_datetime <= ?)',
						userx.id, shiftx.start_datetime, shiftx.end_datetime, userx.id, shiftx.start_datetime, shiftx.end_datetime).any?
			return "unavailable"
		else
			return ""
		end
	end

end