class MicropostsController < ApplicationController
    before_action :ensure_user_logged_in, only: [:create, :destroy]
    before_action :get_post_to_delete,    only: :destroy

    def create
        @micropost = current_user.microposts.build(micropost_params)
        if @micropost.save
            flash[:success] = "Micropost created!"
            redirect_to root_url
        else
            @feed_items = current_user.feed.paginate(page: params[:page])
            render 'static_pages/home'
        end
    end

    def destroy
        @micropost.destroy
        flash[:success] = "Micropost deleted"
        # redirect to the previous page, because micropost's delete link
        # exists in both user's profile page and on home page
        redirect_to request.referrer || root_url
    end

    private

        def micropost_params
            params.require(:micropost).permit(:content, :picture)
        end

        def get_post_to_delete
            @micropost = current_user.microposts.find_by(id: params[:id])
            redirect_to root_url if @micropost.nil?
        end
end
