require 'spec_helper'

describe User do
  before { @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar") }

  	# If I used Factory Girl to create that user then the test "when email address is already taken" would not  break. The reason is that Factory Girl works in the test database while the rest of this code works in the actual database. So there is no conflict when I duplicate the sample user above and try to save it with the same email address, since they are located in different databases.
  	
  	# FactoryGirl.create(:user, name: "Example User", email: "user@example.com") }
  	
  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }

  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }

  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
  	before do
  		@user.save!
  		@user.toggle!(:admin)
  	end

  	it { should be_admin }
  end

  describe "when name is not present" do
  	before { @user.name = " " }
  	it { should_not be_valid }
  end

	describe "when name is too long" do
		before { @user.name = "a" * 51 }	
		it { should_not be_valid }
	end

  describe "when email is not present" do
  	before { @user.email = " " }
  	it { should_not be_valid }
	end

	describe "when email is invalid" do
		it "should be invalid" do
			addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com www--e@gmail.com dtz.or@g...mail.com ..dimi@gmail.c foo..a@gmail.com]
			
			addresses.each do |invalid_address|
				@user.email = invalid_address
				
				expect(@user).not_to be_valid
			end
		end
	end

	describe "when email is valid" do
		it "should be valid" do
			addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
			
			addresses.each do |valid_address|
				@user.email = valid_address
				
				expect(@user).to be_valid
			end
		end
	end

	describe "when email address is already taken" do
		# The trick here is that before checking if @user is valid we create another user (user_with_same_email) that has the same email address.
		before do
			user_with_same_email = @user.dup
			user_with_same_email.email = @user.email.upcase
			user_with_same_email.save
		end

		it { should_not be_valid }
	end

	describe "email address has mixed case" do
		let(:mixed_case_address) { "FoO@BAr.COm" }

		it "should be save as all lower case" do
			@user.email = mixed_case_address
			@user.save
			expect(@user.reload.email).to eq mixed_case_address.downcase
		end
	end

	describe "when password is not present" do
		before do
			# Probably something about "has_secure_password" in user.rb makes it impossible 
			# to change the password from something valid ("foobar") to blank (" "). 
			# That is why we have to create a new @user with blank password to be able to test the presence of the password.
			# The opposite is possible, to change from blank (" ") to something, eg. "foobar".
			@user = User.new(name: "Dimitris", email: "dimitris@mail.com", password: " ", password_confirmation: " " )
		end

		it { should_not be_valid }
	end

	describe "when password does not match confirmation" do
		# Unlike the password, the password_confirmation CAN be changed to something invalid.
		before { @user.password_confirmation = "mismatched_password" }

		it { should_not be_valid }
	end

	describe "with a password that's too short" do
		before { @user.password = @user.password_confirmation = "a" * 5 }
		
		it { should_not be_valid }
	end

	# Authenticating Users
	describe "return value of authenticate method" do
		before { @user.save }
		let(:found_user) { User.find_by(email: @user.email) }

		describe "with valid password" do
			# When the password is correct, the returned value of 
			# the "authenticate" method applied on "found_user" with argument "@user.password"
			# should be "it", @user.
			it { should eq found_user.authenticate(@user.password) }
		end

		describe "with invalid password" do
			# When the password is not correct the returned value of the authenticate method
			# applied on "found_user" should be "false".
			
			let(:returned_value) { found_user.authenticate("invalid_password") }

			it { should_not eq returned_value }
			specify { expect(returned_value).to be_false }
		end
	end

	describe "remember token" do
		before { @user.save }
		its(:remember_token) { should_not be_blank }
	end

	describe "micropost associations" do

		before { @user.save }
		let!(:older_micropost) do
			FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
		end
		let!(:newer_micropost) do
			FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
		end

		# If I hadn't used "let!" instead of "let" then the following test would not break because variables made with let are only created when they are referenced so newer_micropost would be created before older_micropost since they appear in that order in the array below. Then the id of newer_micropost would be 1 and the id of older_micropost would be 2. By default the posts are ordered by id so they would be returned in the array just like shown in the test, first the newer then the older.

		it "should have the right microposts in the right order" do
			expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
		end

		it "should destroy associated microposts" do
			microposts = @user.microposts.to_a
			@user.destroy
			# The following is a safety check just to be sure that the microposts array contains the microposts. If, by mistake, the "to_a" above was deleted then the microposts variable would contain nothing after @user was destroyed.
			expect(microposts).not_to be_empty
			microposts.each do |micropost|
				# Using where instead of "find" because find raises an exception if the record is not found while "where" returns an empty object.
				expect(Micropost.where(id: micropost.id)).to be_empty
			end
		end

		describe "status" do
			let(:unfollowed_post) do
				FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
			end
			let(:followed_user) { FactoryGirl.create(:user) }

			before do
			  @user.follow!(followed_user)
			  3.times { followed_user.microposts.create!(content: "Lorem ipsum Cillum proident ea ut in aliqua.") }
			end

			# Notice how we use "its", to impy that feed is a method (?) of the subject, which is @user. Testing that the feed contains the user's microposts.
			its(:feed) { should include(newer_micropost) }
			its(:feed) { should include(older_micropost) }

			# And does not contain the unfollowed_users micropost.
			its(:feed) { should_not include(unfollowed_post) }

			# And it contains the followed user's microposts.
			its(:feed) do
				followed_user.microposts.each do |micropost|
					should include(micropost)
				end
			end
		end
	end

	# User relationships
	describe "following" do
		let(:other_user) { FactoryGirl.create(:user) }
		before do
			@user.save
			@user.follow!(other_user)
		end

		it { should be_following(other_user) }
		its(:followed_users) { should include(other_user) }

		describe "followed user" do
			subject { other_user }			
			its(:followers) { should include(@user) }
		end

		describe "and unfollowing" do
			before { @user.unfollow!(other_user) }			
			it { should_not be_following(other_user) }
			its(:followed_users) { should_not include(other_user) }
		end
	end
end