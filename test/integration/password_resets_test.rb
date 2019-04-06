require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  def prepare_user_password_reset
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @user = assigns(:user)
  end

  test "valid password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'

    # Valid email
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    
    # check reset_digest is updated from nil to an digest
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    
    # check mail is prepared to be delivered
    assert_equal 1, ActionMailer::Base.deliveries.size
    
    # check for password reset notice
    assert_not flash.empty?
    assert_redirected_to root_url

    # Password reset form
    user = assigns(:user)
    
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # Valid password & confirmation
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }

    # reset digest should be cleared
    assert_nil user.reload.reset_digest

    # log in users
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "invalid email" do
    # trying to initialize reset for invalid email
    post password_resets_path, params: { password_reset: { email: "" } }
    
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # trying to reset with invalid email
    @user = prepare_user_password_reset
    get edit_password_reset_path(@user.reset_token, email: "")
    assert_redirected_to root_url
  end

  test "expired token" do
    # create reset for user
    @user = prepare_user_password_reset
    
    # expired token
    @user.update_attribute(:reset_sent_at, 3.hours.ago)

    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }

    # error report
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end

  test "invalid token" do
    # create reset for user
    @user = prepare_user_password_reset
    
    # invalid token
    get edit_password_reset_path('wrong token', email: @user.email)
    
    # error report
    assert_redirected_to root_url
    follow_redirect!
    assert_match /invalid/i, response.body
  end

  test "reuse reset token" do
    # create reset for user
    @user = prepare_user_password_reset

    # reset password
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }

    # success
    assert is_logged_in?
    
    # log out
    delete logout_path

    # reset should be invalid now
    get edit_password_reset_path(@user.reset_token, email: @user.email)

    assert_redirected_to root_url
    follow_redirect!
    assert_match /invalid/i, response.body
  end

  test "inactive user" do
    # create reset for user
    @user = prepare_user_password_reset
    
    # mark as inactive
    if @user.activated
        @user.toggle!(:activated)    
    end
    
    get edit_password_reset_path(@user.reset_token, email: @user.email)
    assert_redirected_to root_url
    follow_redirect!
    assert_match /inactive/i, response.body
  end

  test "invalid password" do
    # create reset for user
    @user = prepare_user_password_reset
    
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
  end

  test "empty password" do
    # create reset for user
    @user = prepare_user_password_reset

    # reset password
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    
    assert_select "div#error_explanation"
  end


end
