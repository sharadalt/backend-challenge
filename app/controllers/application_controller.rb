class ApplicationController < ActionController::API
  def validate_member_session_token
    raise Exception.new("You need to login first to access this page") if(request.headers['auth-token'].blank?)
    
    member = Member.where(auth_token: request.headers['auth-token']).first
    if member.present?
      @current_member = member
    else
      raise Exception.new("Session expired, or invalid auth token")
    end
    #rescue Exception => e  
  end
end
