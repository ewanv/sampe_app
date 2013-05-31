require 'spec_helper'

describe "User pages" do

	subject { page }

	describe "index" do
		let(:user) { FactoryGirl.create(:user) }
		before(:each) do
			sign_in user
			visit users_path
		end

		it { should have_title('All users') }
		it { should have_content('All users') }

		describe "pagination" do
			before(:all) { 30.times { FactoryGirl.create(:user) } }
			after(:all) { User.delete_all }

			it { should have_selector('div.pagination') }

			it "should list each user" do
				User.paginate(page: 1).each do |user|
					expect(page).to have_selector('li', text: user.name)
				end
			end
		end

		describe "delete links" do

			it { should_not have_link('delete') }

			describe "admin user" do
				let(:admin) { FactoryGirl.create(:admin)  }
				before do
					sign_in admin
					visit users_path
				end

				it { should have_link('delete', href: user_path(User.first)) }
				it "should be able to delete another user" do
					expect { (click_link 'delete') }.to change(User, :count).by(-1)
				end
				it { should_not have_link('delete', href: user_path(admin)) }
			end
		end
	end

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit user_path(user) }

		it { should have_content(user.name) }
		it { should have_title user.name }
	end

	describe "signup page" do
		before { visit signup_path }

		it { should have_content('Sign Up') }
		it { should have_title full_title('Sign Up') }

		let(:submit) { "Create my account" }

		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end
			describe "after submission" do
				before { click_button submit }

				it { should have_title full_title('Sign Up') }
				it { should have_error_message('error') }
				it { should have_content('blank') }
				before do
					fill_in "Name",         with: "Example User"
					fill_in "Email",        with: "user@example.com"
					fill_in "Password",     with: "foobar"
				end
				describe "where passwords don't match" do
					before do
						fill_in "Confirm password", with: "invalid"
						click_button submit
					end
					it { should have_content "doesn't match"}
				end
				describe "where password is too short" do
					before do
						fill_in "Password", with: "short"
						click_button submit
					end
					it { should have_content "too short"}
				end
				describe "where email is invalid" do
					before do
						fill_in "Email",        with: "user@invalid"
						click_button submit
					end
					it { should have_content 'invalid'}
				end
			end
		end
		describe "with valid information" do
			before do
				fill_in "Name",         with: "Example User"
				fill_in "Email",        with: "user@example.com"
				fill_in "Password",     with: "foobar"
				fill_in "Confirm password", with: "foobar"
			end

			it "should create a user" do
				expect { click_button submit }.to change(User, :count).by(1)
			end

			describe "after saving the user" do
				before { click_button submit }

				let(:user) { User.find_by(email: "user@example.com") }

				it { should have_signed_user_in(user.name, "Welcome") }
			end
		end
	end

	describe "edit" do
		let(:user) { FactoryGirl.create(:user) }
		before do 
			sign_in user
			visit edit_user_path(user)
		end

		describe "page" do
			it { should have_content("Update your profile") }
			it { should have_title("Edit user") }
			it { should have_link('change', href: 'http://gravatar.com/emails') }
		end

		describe "with invalid information" do
			before { click_button "Save changes" }

			it { should have_error_message('error') }
		end

		describe "with valid information" do
			let(:new_name) { "New Name" }
			let(:new_email) { "new@example.com" }
			before do
				fill_in "Name", 			with: new_name
				fill_in "Email", 			with: new_email
				fill_in "Password", 		with: user.password
				fill_in "Confirm password", with: user.password
				click_button "Save changes"
			end

			it { should have_signed_user_in(new_name, "updated") }
			specify { expect(user.reload.name).to eq new_name }
			specify { expect(user.reload.email).to eq new_email }
		end

		describe "forbidden attributes" do
			let(:params) do
				{ user: { admin: true, password: user.password, 
					password_confirmation: user.password } }
			end
			before { patch user_path(user), params }
			specify { expect(user.reload).not_to be_admin }
		end
	end
end
