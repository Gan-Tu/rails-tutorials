class PasswordResetsController < ApplicationController
  before_action :get_user,    only: [:edit, :update]
  before_action :valid_user,  only: [:edit, :update]
  # case 1: An expired password reset
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
        @user.create_reset_digest
        @user.send_password_reset_email
        flash[:info] = "Email sent with password reset instructions"
        redirect_to root_url
    else
        # note, best practice should be email sent with password
        # reset instructions, if the email exists
        flash.now[:danger] = "Email address not found"
        render "new"
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
        # case 3: A failed update (which initially looks “successful”)
        # due to an empty password and confirmation

        # we explicitedly check this, because we allow update_attributes
        # to have nil password/password_confirmation, as designed by the
        # allow_nil: true in user model, and as required by profile setting
        # updates.
        @user.errors.add(:password, "can't be empty")
        render 'edit'
    elsif @user.update_attributes(user_params)
        # case 4: A successful update
        log_in @user
        # invalidates reset digest
        @user.update_attribute(:reset_digest, nil)
        flash[:success] = "Password has been reset."
        redirect_to @user
    else
        # case 2: A failed update due to an invalid password
        render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirms a valid user.
    def valid_user
        unless (@user && @user.activated? &&
                @user.authenticated?(:reset, params[:id]))
            if @user && !@user.activated?
                flash[:danger] = "Cannot reset password of inactive user"
            elsif @user && !@user.authenticated?(:reset, params[:id])
                flash[:danger] = "Invalid reset link"
            end

            redirect_to root_url
        end
    end

    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end

end
