require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "root layout links" do
    # check for links
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    # check for titles
    get contact_path
    assert_select "title", full_title("Contact")
    get signup_path
    assert_select "title", full_title("Sign Up")
  end

  test "all users layout link" do
    get users_path
    # should fail, because we are not logged in
    assert_redirected_to login_url
    follow_redirect!
    # now, let's log in
    log_in_as( users(:michael) )
    assert_redirected_to users_path
    follow_redirect!
    # check site layouts
    assert_select "ul.users"
  end
end
