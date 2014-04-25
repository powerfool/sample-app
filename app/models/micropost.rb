class Micropost < ActiveRecord::Base
	belongs_to :user
	# DESC is SQL for "descending"
	default_scope -> { order('created_at DESC') }
	validates :user_id, presence: true
	validates :content, presence: true, length: { maximum: 140 }

	def self.from_users_followed_by(user)
		# This implementation is inefficient. The reason is that the following command puts all followed_user_ids into memory by creating this array. What we need to do is get the microposts from the followed users and the current user. What we can do is push the finding of followed_user_ids into the database by using a subselect.
		#followed_user_ids = user.followed_user_ids
		#where("user_id IN (?) OR user_id = ?", followed_user_ids, user)	
		followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
		where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user.id)
	end
end