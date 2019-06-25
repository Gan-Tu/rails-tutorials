class MicropostsController < ApplicationController
    before_action :ensure_user_logged_in, only: [:create, :destroy]

    def create
    end

    def destroy
    end

end
