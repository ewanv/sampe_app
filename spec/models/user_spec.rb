# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do

	before { @user = User.new(name: "Example User", username: "Username", email: "user@example.com", 
		password: "foobar", password_confirmation: "foobar") }

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
	it { should respond_to(:username) }

	it { should be_valid }
	it { should_not be_admin }

	describe "with admin attributes set to 'true'" do
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

	describe "when email is not present" do
		before { @user.email = " " }
		it { should_not be_valid }
	end

	describe "when name is too long" do
		before { @user.name = "a" * 51 }
		it { should_not be_valid }
	end

	describe "when username is not present" do
		before { @user.username = " " }
		it { should_not be_valid }
	end

	describe "when username is invalid" do
		before { @user.username = "user name" }
		it { should_not be_valid }
	end

	describe "when username is already taken" do
		let(:user_with_same_username) { @user.dup }
		before do
			user_with_same_username.email = "email@example.com"
			user_with_same_username.save
		end
		it { should_not be_valid }
	end

	describe "when email is invalid" do
		it "should be invalid" do
			addresses = %w[user@foo,com user_at_foo.org example.user@foo.
				foo@bar_baz.com foo@bar+baz.com foobar@example..com]
				addresses.each do |invalid_address|
					@user.email = invalid_address
					@user.should_not be_valid
				end
			end				
		end

		describe "when email format is valid" do
			it "should be valid" do
				addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
				addresses.each do |valid_address|
					@user.email = valid_address
					@user.should be_valid
				end      
			end
		end

		describe "when email address is already taken" do
			before do
				user_with_same_email = @user.dup
				user_with_same_email.email = @user.email.upcase
				user_with_same_email.save
			end

			it { should_not be_valid }
		end

		describe "email address with mixed case" do
			let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

			it "should be saved as all lower-case" do
				@user.email = mixed_case_email
				@user.save
				expect(@user.reload.email).to eq mixed_case_email.downcase
			end
		end

		describe "when password is not present" do
			before do
				@user = User.new(name: "Michael Hartl", email: "mhartl@example.com",
					password: " ", password_confirmation: " ")
			end
			it { should_not be_valid }
		end

		describe "when password doesn't match confirmation" do
			before { @user.password_confirmation = "mismatch" }
			it { should_not be_valid }
		end

		describe "when password confirmation is nil" do
			before do
				@user = User.new(name: "Michael Hartl", email: "mhartl@example.com",
					password: "foobar", password_confirmation: nil)
			end
			it { should_not be_valid }
		end

		describe "return value of authenticate method" do
			before { @user.save }
			let (:found_user) { User.find_by(email: @user.email) }

			describe "with valid password" do
				it { should == found_user.authenticate(@user.password) }
			end

			describe "with invalid password" do
				let(:user_for_invalid_password) { found_user.authenticate("invalid") }

				it { should_not == user_for_invalid_password }
				specify { user_for_invalid_password.should be_false}
			end
		end

		describe "when password is too short" do
			before { @user.password = @user.password_confirmation = "a" * 5}
			it { should_not be_valid }
		end

		describe "remember token" do
			before { @user.save }
			its(:remember_token) { should_not be_blank }
		end

		describe "microposts associations" do

			before { @user.save }
			let!(:older_micropost) do
				FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
			end
			let!(:newer_micropost) do
				FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
			end

			it "should have the right microposts in the right order" do
				expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
			end

			it "should destroy associated microposts" do
				microposts = @user.microposts.to_a
				@user.destroy
				expect(microposts).not_to be_empty
				microposts.each do |micropost|
					expect(Micropost.where(id: micropost.id)).to be_empty
				end
			end

			describe "status" do
				let(:unfollowed_post) do
					FactoryGirl.create(:micropost, user: FactoryGirl.create(:user), 
						created_at: 3.hours.ago) 
				end
				let(:followed_user) { FactoryGirl.create(:user) }
				let!(:reply) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user),
					content: "@#{@user.username} Aye bru!", created_at: 2.hours.ago) }

				before do
					@user.follow! (followed_user)
					3.times { followed_user.microposts.create!(content: "Lorem ipsum",
					created_at: 4.days.ago) }
				end

				its(:feed) { should include(older_micropost) }
				its(:feed) { should include(newer_micropost) }
				its(:feed) { should include(reply) }
				its(:feed) { should_not include(unfollowed_post) }

				its(:feed) do
					followed_user.microposts.each do |micropost|
						should include(micropost)
					end
				end
				let(:feed) { @user.feed }
				it "should have a feed that's in the right order" do
					expect(feed).to eq [newer_micropost, reply, older_micropost
						] + followed_user.microposts.to_a
				end
			end
		end

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

			describe "destroying following users" do
				it "should destroy associated relationships" do
					relationships = @user.relationships.to_a
					@user.destroy
					expect(relationships).not_to be_empty
					relationships.each do |relationship|
						expect(Relationship.where(id: relationship.id)).to be_empty
					end
				end
			end

			describe "destroying followed users" do
				it "should destroy associated relationships" do
					relationships = other_user.reverse_relationships.to_a
					other_user.destroy
					expect(relationships).not_to be_empty
					relationships.each do |relationship|
						expect(Relationship.where(id: relationship.id)).to be_empty
					end
				end
			end
		end
	end

