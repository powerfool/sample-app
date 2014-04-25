class UsersController < ApplicationController
  # Returns a redirection to signin_url unless the user is already signed in. So, if the user is already signed in it does nothing and the next before_action is executed.
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  
  # Returns a redirection to root_url unless the @user found from params[:id] is also the user that has been authenticated.
  before_action :correct_user, only: [:edit, :update]

  before_action :admin_user, only: :destroy

  def new
    unless signed_in?
      @user = User.new
    else
      redirect_to(root_url)
    end
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def create 
    unless signed_in?
      @user = User.new(user_params)
    	if @user.save
        sign_in @user 
    		flash[:success] = "Welcome to the SampleApp!" 
    		redirect_to @user
    	else
    		render 'new'
    	end
    else
      redirect_to(root_url)
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    # Make sure that the current user (an administrator) is not deleting themselves.
    if current_user?(@user)
      flash[:error] = "Don't."
    else
      @user.destroy
      flash[:success] = "User deleted."
    end
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private 

    # Note that "admin" is not in the list of permitted attributes. This is what prevents arbitrary users from granting themselves administrative access to our application. 
  	def user_params
  		params.require(:user).permit(:name, :email, :password, :password_confirmation) #, :admin)
  	end

    # Before filters (before action)

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin? 
    end
end