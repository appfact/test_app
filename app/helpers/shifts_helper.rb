module ShiftsHelper

	def shift_filled?(shiftid)
		!Shift.find(shiftid).fk_user_worker.nil? ? true : false
	end

	def can_delete_shift(shiftx)
		(!current_user.admin? || current_user.business_id != shiftx.business_id) ? 
		false : true
	end

end