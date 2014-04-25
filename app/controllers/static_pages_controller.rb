class StaticPagesController < ApplicationController
  def home
    if signed_in?
      # The test will break if we forget to sign the user in.
    	@micropost = current_user.microposts.build #if signed_in?
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end

