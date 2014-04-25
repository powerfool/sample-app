module SessionsHelper

	def sign_in(user)
		# Create a new remember token
		remember_token = User.new_remember_token

		# Save the raw token in the user's browser, in a cookie.
		# cookies.permament creates a cookie that expires 20 years in the future. It's equal to:
		# cookies[:remember_token] = { 	value: remember_token, 
		#																expires: 20.years.from_now.utc }
		cookies.permanent[:remember_token] = remember_token

		# Save the hashed token in the database.
		user.update_attribute(:remember_token, User.hash(remember_token))

		# Set the current user in the session equal to the given user
		self.current_user = user
	end

	def sign_out
		current_user.update_attribute(:remember_token, User.hash(User.new_remember_token))
		cookies.delete(:remember_token)
		self.current_user = nil
	end

	def current_user=(user)
		@current_user = user
	end

	def current_user
		remember_token = User.hash(cookies[:remember_token])
		@current_user ||= User.find_by(remember_token: remember_token)
	end

	def current_user?(user)
		user == current_user
	end

	def signed_in?
		!current_user.nil?
	end

	def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

	def redirect_back_or(default)
		# Redirect to the URL saved at session[:return_to] unless this one is nil in which case redirect to the default URL. What is the default URL? The default URL is given in sessions_controller.rb when the redirect_back_or is called.
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	def store_location
		session[:return_to] = request.url if request.get?
	end
end
