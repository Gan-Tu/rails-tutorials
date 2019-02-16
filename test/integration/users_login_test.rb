require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

    test "login with invalid information" do 
        get login_path
        assert_template 'sessions/new'
        post login_path, params: { session: { email: "", password: "" }}
        # should appear error message on login page
        assert_template 'sessions/new'
        assert_not flash.empty?
        # but should not reappear error message again
        get root_path
        assert flash.empty?
    end
end
