class MicropostsController < ApplicationController
	before_action :signed_in_user, only: [:create, :destroy]
	before_action :correct_user, only: :destroy

	def create
		@micropost = current_user.microposts.build(micropost_params)
		if @micropost.save
			flash[:success] = "Micropost created!"
			redirect_to root_url
		else
			# Not so DRY since the following command should exist only in Static Pages Controller.
			# Fill @feed_items with the current_users' feed items so that the variable is not returned empty.
			# However, paginate will not work with these feeds. The reason is that when we click "Post" we are in the microposts controller and after the failed submission we stay there. Notice how the URL changes to /microposts so when the user clicks the second page of the feeds the params contains /microposts?page=2 but there's no route to GET /microposts. How can this be fixed?!
			@feed_items = current_user.feed.paginate(page: params[:page])
			render 'static_pages/home'
		end
	end

	def destroy
		@micropost.destroy
		redirect_to root_url
	end

	private

		def micropost_params
			params.require(:micropost).permit(:content)
		end

		def correct_user
			# find_by returns nil if nothing is found in contrast with find which raises an exception if nothing is found. 
			# I could use find but with the code:
			# @micropost = Micropost.find(params[:id])
			# rescue
			# redirect_to root_url
			# end
			# "Rescue" is there to handle the exception.
			@micropost = current_user.microposts.find_by(id: params[:id])
			redirect_to root_url if @micropost.nil?
		end
end