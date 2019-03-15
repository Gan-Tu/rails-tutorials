require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

    def setup
        @user       = users(:michael)
        @other_user = users(:archer)
    end

    test "should get new" do
        get signup_path
        assert_response :success
    end 

    test "should redirect edit when not logged in" do
        get edit_user_path(@user)
        assert_not flash.empty?
        assert_redirected_to login_url
    end

    test "should redirect update when not logged in" do
        patch user_path(@user), params: { user: { name: @user.name,
                                                  email: @user.email } }
        assert_not flash.empty?
        assert_redirected_to login_url
    end

    test "should redirect edit when logged in as wrong user" do
        log_in_as(@other_user)
        get edit_user_path(@user)
        assert flash.empty?
        assert_redirected_to root_url
    end

    test "should redirect update when logged in as wrong user" do
        log_in_as(@other_user)
        patch user_path(@user), params: { user: { name: @user.name,
                                                  email: @user.email } }
        assert flash.empty?
        assert_redirected_to root_url
    end

    test "should redirect index when not logged in" do
        get users_path
        assert_redirected_to login_url
    end

    test "should have friendly forwarding after logging in" do
        get edit_user_path(@user)
        # should fail and redirect to login
        assert_not flash.empty?
        assert_redirected_to login_url
        follow_redirect!
        # forwarding url should be set correctly
        assert_not_nil session[:forwarding_url]
        assert_includes session[:forwarding_url], edit_user_path(@user)
        # should have friendly redirect
        log_in_as(@user)
        assert_redirected_to edit_user_path(@user)
        # should clear the forwarding_url
        assert_nil session[:forwarding_url]
      end

    test "should not allow the admin attribute to be edited via the web" do
        # cannot set admin
        log_in_as(@other_user)
        assert_not @other_user.admin?
        patch user_path(@other_user), params: {
                                        user: { password:              "password",
                                                password_confirmation: "password",
                                                admin: true } }
        assert_not @other_user.admin?
        # cannot unset admin
        log_in_as(@user)
        assert @user.admin?
        patch user_path(@user), params: {
                                        user: { password:              "password",
                                                password_confirmation: "password",
                                                admin: false } }
        assert @user.admin?
    end

    test "should redirect destroy when not logged in" do
        assert_no_difference 'User.count' do
            delete user_path(@user)
        end
        assert_redirected_to login_url
    end

    test "should redirect destroy when logged in as a non-admin" do
        log_in_as(@other_user)
        assert_no_difference 'User.count' do
            delete user_path(@user)
        end
        assert_redirected_to root_url
    end

end
