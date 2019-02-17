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

    # Remembers a user in a persistent session
    def remember(user)
        user.remember
        # by assigning to signed, it automatically encrypts it
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    # Return the current logged-in user (if any)
    def current_user
        # temporary sessions
        if (user_id = session[:user_id]) # NOTE: it's an assignment AND nil check
            # the method 'find_by' return nil if 'id' doesn't exist, in contrast
            # to the method 'find', which raises an exception
            # we don't want to repeatedly fetch from database, so we save it
            # as a instance variable @current_user
            @current_user ||= User.find_by(id: user_id)
        # or permanent sessions 
        # NOTE: it's an assignment AND nil check
        elsif (user_id = cookies.signed[:user_id])
            # by accessing signed, it automatically decrypts it
            user = User.find_by(id: user_id)
            if user && user.authenticated?(cookies[:remember_token])
                log_in(user)
                @current_user = user
            end
        end
    end

    # Return true if the user is logged in, false otherwise
    def logged_in?
        return !current_user.nil?
    end

    # Forgets a persistent session
    def forget(user)
        user.forget
        # by assigning to signed, it automatically encrypts it
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # Logs out the current user
    def log_out
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end
end
