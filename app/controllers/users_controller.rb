class UsersController < ApplicationController

    before_action :ensure_user_logged_in, only: [:index, :edit, :update, :destroy, :following, :followers]
    before_action :ensure_correct_user,   only: [:edit, :update]
    before_action :ensure_admin_user,     only: :destroy

    def index
        if current_user.admin?
            @users = User.paginate(page: params[:page])
        else
            @users = User.where(activated: true).paginate(page: params[:page])
        end
        @users = @users.order('created_at ASC')
    end

    def show
        @user = User.find(params[:id])
        @microposts = @user.microposts.paginate(page: params[:page])
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(safe_user_params)
        if @user.save
            @user.send_activation_email
            flash[:info] = "Please check your email to activate your account."
            redirect_to root_url
        else
            render "new"
        end
    end

    def edit
    end

    def destroy
        User.find(params[:id]).destroy
        flash[:success] = "User deleted"
        redirect_to users_url
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

    def following
        @title = "Following"
        @user  = User.find(params[:id])
        @users = @user.following.paginate(page: params[:page])
        render 'show_follow'
    end

    def followers
        @title = "Followers"
        @user  = User.find(params[:id])
        @users = @user.followers.paginate(page: params[:page])
        render 'show_follow'
    end

    private

        def safe_user_params
            return params.require(:user).permit(:name, :email, :password,
                                                :password_confirmation)
        end

        ######## Before filters ########

        # Returns true if the given user is the current user.
        def is_current_user?(user)
            user == current_user
        end

        # Confirms the correct user.
        def ensure_correct_user
            @user = User.find(params[:id])
            redirect_to(root_url) unless is_current_user?(@user)
        end

        # Confirms an admin user.
        def ensure_admin_user
            redirect_to(root_url) unless current_user.admin?
        end
end
