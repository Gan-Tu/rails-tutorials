module SessionsHelper

    # Logs in the given user
    def log_in(user)
        # Because temporary cookies created using the session method are
        # automatically encrypted, the code is secure
        # This applies only to temporary sessions initiated with the session 
        # method, though, and is not the case for persistent sessions created
        # using the cookies method
        session[:user_id] = user.id
    end

    # Return the current logged-in user (if any)
    def current_user
        if session[:user_id]
            # the method 'find_by' return nil if 'id' doesn't exist, in contrast
            # to the method 'find', which raises an exception
            # we don't want to repeatedly fetch from database, so we save it
            # as a instance variable @current_user
           return @current_user ||= User.find_by(id: session[:user_id])
        end
    end

    # Return true if the user is logged in, false otherwise
    def logged_in?
        return !current_user.nil?
    end
end
