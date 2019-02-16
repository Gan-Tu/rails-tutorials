require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

    def setup
        @user = users(:michael)
    end

    test "login with invalid information" do 
        get login_path
        assert_template 'sessions/new'
        # should have non-logged-in user links
        assert_nonlogin_user_links
        # submit invalid information
        post login_path, params: { session: { email: "", password: "" }}
        # should appear error message on login page
        assert_template 'sessions/new'
        assert_not flash.empty?
        # but should not reappear error message again
        get root_path
        assert flash.empty?
        # should have non-logged-in user links
        assert_nonlogin_user_links
    end

    test "login with valid information" do
        get login_path
        assert_template 'sessions/new'
        # should have non-logged-in user links
        assert_nonlogin_user_links
        # submit valid information
        post login_path, params: { session: {   email: @user.email, 
                                                password: "password" }}
        # should NOT appear error message before redirect
        assert flash.empty?
        # should redirect to user's show page
        assert_redirected_to @user
        follow_redirect!
        assert_template 'users/show'
        # should NOT appear error message on show page
        assert flash.empty?
       # should have logged-in user links
        assert_login_user_links
    end

    def assert_login_user_links
        # should NOT have non-logged-in user paths
        assert_select "a[href=?]", login_path, count: 0
        # should have logged-in user paths
        assert_select "a[href=?]", logout_path
        assert_select "a[href=?]", user_path(@user)
        assert_select "a[href=?]", logout_path
    end

    def assert_nonlogin_user_links
        # should have non-logged-in user paths
        assert_select "a[href=?]", login_path
        # should NOT have logged-in user paths
        assert_select "a[href=?]", logout_path, count: 0
        assert_select "a[href=?]", user_path(@user), count: 0
        assert_select "a[href=?]", logout_path, count: 0
    end
end
