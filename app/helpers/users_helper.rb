module UsersHelper

	
  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

  def user_available_shifts_helper
    @permissionsarray = []
    @userspermissions = current_user.firm_permissions.where(:status => true)
    #move these variables to helpers
    @userspermissions.each do |permission|
      @permissionsarray.push(permission.firm_id)
    end
    return Shift.where("firm_id in (?) AND fk_user_worker is ? 
                  AND start_datetime > ?", @permissionsarray, nil, Time.now.to_datetime)
    end

  def confirmed_holidays
    Shift.where(fk_user_worker: current_user.id, status: "true").
        where('end_datetime > ? AND allocation_type = ?', Time.now.to_datetime, 10)
  end

  def holidays_past
       Shift.where(fk_user_worker: current_user.id, status: true).
        where('end_datetime < ? AND allocation_type = ?', Time.now.to_datetime, 10)
  end

  def holidays_requests
       Shift.where(fk_user_worker: current_user.id, status: nil).
        where('end_datetime > ? AND allocation_type = ?', Time.now.to_datetime, 10)
  end

  def unavailables
    Shift.where(fk_user_worker: current_user.id).
        where('end_datetime > ? AND allocation_type = ?', Time.now.to_datetime, 12)
  end

  def user_permissions
    return current_user.firm_permissions.where(:status => true)
  end


end