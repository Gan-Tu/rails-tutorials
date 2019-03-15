class UsersController < ApplicationController

    before_action :ensure_user_logged_in, only: [:edit, :update]
    before_action :ensure_correct_user,   only: [:edit, :update]

    def show
        @user = User.find(params[:id]) 
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(safe_user_params)
        if @user.save
            log_in @user
            flash[:success] = "Welcome to the Sample App"
            redirect_to user_url(@user)
            # equivalent to: redirect_to @user
        else
            render "new"
        end
    end

    def edit
    end

    def update
        if @user.update_attributes(safe_user_params)
          # Handle a successful update.
            flash[:success] = "Profile updated"
            redirect_to @user
        else
          render 'edit'
        end
    end

    private

        def safe_user_params
            return params.require(:user).permit(:name, :email, :password,
                                                :password_confirmation)
        end

        ######## Before filters ########

        # Confirms a logged-in user.
        def ensure_user_logged_in
          unless logged_in?
            store_location
            flash[:danger] = "Please log in."
            redirect_to login_url
          end
        end

        # Returns true if the given user is the current user.
        def is_current_user?(user)
        user == current_user
        end

        # Confirms the correct user.
        def ensure_correct_user
          @user = User.find(params[:id])
          redirect_to(root_url) unless is_current_user?(@user)
        end
end
