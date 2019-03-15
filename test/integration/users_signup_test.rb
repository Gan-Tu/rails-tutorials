require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

    test "not using valid custom signup post route" do
        get signup_path
        assert_select 'form[action="/signup"]'
    end

    test "valid signup information" do
        get signup_path
        # should create user without error
        assert_difference 'User.count' do
            post_to_signup(name: "Test User")
        end
        follow_redirect!
        # show the new user page with a flash and correct information
        assert_template 'users/show'
        assert_not flash.empty?
        assert_select "div.alert-success", text: "Welcome to the Sample App"
        assert_select "section.user_info h1 img[class=gravatar]"
        assert_select "section.user_info h1", text: "Test User"
        # assert it's logged in by default
        assert is_logged_in?
    end


    test "invalid signup information" do
        get signup_path
        assert_no_difference 'User.count' do 
          post_to_signup(name: "")
        end
        assert_template 'users/new'
    end


    test "missing signup error information upon failure" do
        get signup_path
        
        # name must not be blank, or error message should appear
        post_to_signup(name: " ")
        assert_field_error("Name", "Name can't be blank")
        
        # name has a length limit, or error message should appear
        post_to_signup(name: "1"*51)
        assert_field_error("Name", "Name is too long (maximum is 50 characters)")

        # email must not be blank, or error message should appear
        post_to_signup(email: " ")
        assert_field_error("Email", "Email can't be blank")

        # email must be valid, or error message should appear
        post_to_signup(email: "hi@example")
        assert_field_error("Email", "Email is invalid")

        # email has a length limit, or error message should appear
        post_to_signup(email: "1"*300)
        assert_field_error("Email", 
            "Email is too long (maximum is 255 characters)")

        # password must not be blank
        post_to_signup(password: " ")
        assert_field_error("Password", "Password can't be blank")

        # password has a length limit, or error message should appear
        post_to_signup(password: "1"*5)
        assert_field_error("Password", 
            "Password is too short (minimum is 6 characters)")

        # password and confirmation must match
        post_to_signup(password: "password", password_confirmation: "123456")
        assert_field_error("Password confirmation", 
            "Password confirmation doesn't match Password")

    end


    def post_to_signup( name: "Example User", 
                        email:"user@example.com", 
                        password:"password", 
                        password_confirmation:"password")
        post users_path, params: { user: {   name:  name,
                                             email: email,
                                             password: password,
                                             password_confirmation: password_confirmation } }
    end


    def assert_field_error(field, errorMsg="")
        assert_select 'div#error_explanation'
        assert_select 'div.field_with_errors', text: field
        unless errorMsg.empty?
           assert_select "div#error_explanation li", text: errorMsg 
        end
    end

end