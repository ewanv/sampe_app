require 'spec_helper'

describe "MicropostPages" do

	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	before { sign_in user }

	describe "micropost creation" do
		before { visit root_path }

		describe "with invalid information" do
			it "should not create a micropost" do
				expect{ click_button "Post" }.not_to change(Micropost, :count)
			end
		end

		describe "error messages" do
			before { click_button "Post" }
			it { should have_error_message("error") }
		end

		describe "with valid information" do
			before { fill_in 'micropost_content', with: "Lorem ipsum" }
			it "should create a micropost" do
				expect { click_button "Post" }.to change(Micropost, :count).by(1)
			end
		end
	end

	describe "micropost destruction" do
		before { FactoryGirl.create(:micropost, user: user) }

		describe "as correct user" do
			before { visit root_path }
			
			it "should delete a micropost" do
				expect { click_link "delete" }.to change(Micropost, :count).by(-1) 
			end
		end
	end

	describe "pagination" do
		before(:each) do
			50.times { FactoryGirl.create(:micropost, user: user) } 
			visit root_path 
		end
		after(:all) do
			Micropost.delete_all 
			User.delete_all
		end

		it { should have_selector('div.pagination') }

		it "should have each post" do
			Micropost.all.page(1) do |post|
				expect(page).to have_selector('li', text: post.content)
			end
		end
	end


	describe "replies" do
		let(:other_user) { FactoryGirl.create(:user) }

		describe "single reply" do
			let!(:reply) { FactoryGirl.create(:micropost, user: user,
				content:("@#{other_user.username} Aye bru!")) }

			before do
				sign_in other_user
				visit root_path
			end
			it { should have_content(reply.content) }
		end

		describe "multiple replies" do
			let(:third_user) { FactoryGirl.create(:user) }
			let!(:reply) { FactoryGirl.create(:micropost, user: user,
				content:("@#{other_user.username} @#{third_user.username} Aye bru!")) }
			describe "first user" do
				before do
					sign_in other_user
					visit root_path
				end
				it { should have_content(reply.content) }
				
			end

			describe "second user" do
				before do
					sign_in third_user
					visit root_path
				end
				it { should have_content(reply.content) }
				
			end
		end
	end
end
