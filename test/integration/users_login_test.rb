require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

    def setup
        @user = users(:michael)
    end

    test "login with invalid information" do
        get login_path
        assert_template 'sessions/new'
        # should have non-logged-in user links
        assert_is_nonlogin_user_links
        # submit invalid information
        post login_path, params: { session: { email: "", password: "" }}
        # should appear error message on login page
        assert_template 'sessions/new'
        assert_not flash.empty?
        # but should not reappear error message again
        get root_path
        assert flash.empty?
        # should have non-logged-in user links
        assert_is_nonlogin_user_links
        assert_not is_logged_in?
    end

    test "login with valid information followed by a logout" do
        get login_path
        assert_template 'sessions/new'
        # should have non-logged-in user links
        assert_is_nonlogin_user_links

        # log in with valid information
        post login_path, params: { session: {   email: @user.email,
                                                password: "password" }}
        # should NOT appear error message before redirect
        assert flash.empty?

        # should redirect to user's home page
        assert_redirected_to root_url
        follow_redirect!

        # should NOT appear error message on show page
        assert flash.empty?
        # should have logged-in user links
        assert_is_login_user_links
        assert is_logged_in?

        # then, log out!
        delete logout_path
        assert_not is_logged_in?

        # redirect
        assert_redirected_to root_path
        follow_redirect!
        assert_is_nonlogin_user_links
    end


    def assert_is_login_user_links
        # should NOT have non-logged-in user paths
        assert_select "a[href=?]", login_path, count: 0
        # should have logged-in user paths
        assert_select "a[href=?]", logout_path
        assert_select "a[href=?]", user_path(@user)
        assert_select "a[href=?]", logout_path
    end

    def assert_is_nonlogin_user_links
        # should have non-logged-in user paths
        assert_select "a[href=?]", login_path
        # should NOT have logged-in user paths
        assert_select "a[href=?]", logout_path, count: 0
        assert_select "a[href=?]", user_path(@user), count: 0
        assert_select "a[href=?]", logout_path, count: 0
    end

    test "login with remembering" do
        log_in_as(@user, remember_me: '1')
        assert_not_empty cookies[:remember_token]
        assert_equal cookies[:remember_token], assigns(:user).remember_token
    end

    test "login without remembering" do
        # Log in to set the cookie.
        log_in_as(@user, remember_me: '1')
        # Log in again and verify that the cookie is deleted.
        log_in_as(@user, remember_me: '0')
        assert_empty cookies[:remember_token]
    end
end
