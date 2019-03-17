require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

    def setup
        @admin     = users(:michael)
        @non_admin = users(:archer)
    end

    test "index as non-admin, without non-activated users" do
        log_in_as(@non_admin)
        get users_path
        assert_select 'a', text: 'delete', count: 0
        # unactivated users should NOT exist
        unactivated_users = User.where(activated: false)
        unactivated_users.each do |user|
            assert_select 'a[href=?]', user_path(user), count: 0
        end
    end

    test "index as admin including pagination, delete links, and activation status" do
        log_in_as(@admin)
        get users_path

        assert_template 'users/index'
        assert_select 'div.pagination'

        # check for unactivated users
        num_unactivated_users = 0
        
        first_page_of_users = User.paginate(page: 1)
        first_page_of_users.each do |user|
            assert_select 'a[href=?]', user_path(user), text: user.name
            if user == @admin
                # cannot delete oneself
                assert_select 'a[href=?][data-method=delete]', user_path(user), count: 0
            else
                assert_select 'a[href=?]', user_path(user), text: 'delete'
            end
            if !user.activated?
                num_unactivated_users +=1
            end
        end
        assert_select "i", text: "User account is not activated",
                           count: num_unactivated_users
        assert_difference 'User.count', -1 do
            delete user_path(@non_admin)
        end
        
    end
end
