class User < ActiveRecord::Base
	has_many :microposts, dependent: :destroy
	
	# A user has many relationships and the foreign key "follower_id" connects the users table with the relationships table.
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy

	# A user has many reverse relationships and the foreign key "followed_id" connects the followed users table with the relationships table.
	has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy

	has_many :followed_users, through: :relationships, source: :followed
	has_many :followers, through: :reverse_relationships, source: :follower 

	before_save { email.downcase! }
	# The above could also be: self.email = email.downcase

	before_create :create_remember_token

	validates :name, presence: true, length: { maximum: 50 }
	# This is the original regex from the Tutorial. This one doesn't catch a double dot or dash, eg. dimitris..asdf@gmail.com
	#VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 

	# This is my regex that is true only if there is a character after ever dot or dash. That way there can be no ".." or "--" or ".-" in the email address.
	VALID_EMAIL_REGEX = /\A\w+([\-.+]?\w+)+@[a-z\d]+([\-.]?[a-z\d]+)+\.[a-z]+\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, length: { minimum: 6 }

	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.hash(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def feed
		# We use the ? so that id is properly escaped before being inserted in the query. In this way we can avoid an SQL injection.
		#Micropost.where("user_id = ?", id)
		Micropost.from_users_followed_by(self)
	end

	def following?(other_user)
		relationships.find_by(followed_id: other_user.id)
	end

	def follow!(other_user)
		relationships.create!(followed_id: other_user.id)
	end

	def unfollow!(other_user)
		relationships.find_by(followed_id: other_user.id).destroy
	end

	private 

		def create_remember_token
			self.remember_token = User.hash(User.new_remember_token)
		end
end
