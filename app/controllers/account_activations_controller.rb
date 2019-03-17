class AccountActivationsController < ApplicationController

    def edit
        user = User.find_by(email: params[:email])
        # activate user for the first time
        if user && !user.activated? && user.authenticated?(:activation, params[:id])
            user.update_attribute(:activated,    true)
            user.update_attribute(:activated_at, Time.zone.now)
            log_in user
            flash[:success] = "Account activated!"
            redirect_to user
        # duplicate activation
        elsif user && user.activated?
            flash[:warning] = "Account already activated!"
            redirect_to root_url
        # Invalid activation
        else
            flash[:danger] = "Invalid activation link"
            redirect_to root_url
        end
    end
end
