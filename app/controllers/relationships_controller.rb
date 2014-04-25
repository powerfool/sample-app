class RelationshipsController  < ApplicationController
	before_action :signed_in_user

	def create
		# Params contains a relationship hash with a :followed_id key. This refers to the user that will be followed, @user.
		@user = User.find(params[:relationship][:followed_id])
		current_user.follow!(@user)
		respond_to do |format|
			format.html { redirect_to @user }
			format.js
		end
	end

	def destroy
		# The Relationships Controller uses the id of the relationship to be destroyed from the params submitted when the "Unfollow" button was clicked and then finds the user to be unfollowed by looking who is the followed user in that relationship.
		@user = Relationship.find(params[:id]).followed
		current_user.unfollow!(@user)
		respond_to do |format|
			format.html { redirect_to @user }
			format.js
		end
	end
end