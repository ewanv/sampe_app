require 'spec_helper'

describe "User pages" do

	subject { page }

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
				it { should have_content('error') }
				it { should have_content('blank') }
				before do
					fill_in "Name",         with: "Example User"
					fill_in "Email",        with: "user@example.com"
					fill_in "Password",     with: "foobar"
				end
				describe "where passwords don't match" do
					before do
						fill_in "Confirmation", with: "invalid"
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
				fill_in "Confirmation", with: "foobar"
			end

			it "should create a user" do
				expect { click_button submit }.to change(User, :count).by(1)
			end

			describe "after saving the user" do
				before { click_button submit }

				let(:user) { User.find_by(email: "user@example.com") }

				it { should have_link('Sign out') }
				it { should have_title(user.name) }
				it { should have_selector('div.alert.alert-success', text: "Welcome") }
			end
		end
	end
end
