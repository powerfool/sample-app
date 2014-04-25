class SessionsController < ApplicationController

	def new
	end

	def create		
		user = User.find_by(email: params[:email].downcase)
		if user && user.authenticate(params[:password])
			# If the user exists and they give a correct password,
			# sign the user in and redirect to the user's show page.
			sign_in user
			redirect_back_or user 
		else
			# Create an error message and re-render the signin form.
			flash.now[:error] = 'Invalid email/password combination'
			render 'new'
		end
	end

	def destroy
		sign_out
		flash[:success] = "You have been signed-out. See you soon!"
		redirect_to root_url
	end
end
