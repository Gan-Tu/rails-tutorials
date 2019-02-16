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
end
