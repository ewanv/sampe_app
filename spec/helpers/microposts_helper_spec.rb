require 'spec_helper'

describe MicropostsHelper do

	describe "reply links" do

		describe "content with no reply tags" do
			let(:content) { "content that shouldn't change" }
			it "should not change" do
				add_reply_links_to(content).should eq "content that shouldn't change"
			end
			
		end

		describe "content with reply tags" do
			let(:user) { FactoryGirl.create(:user) }
			let(:other_user) { FactoryGirl.create(:user) }
			let(:content) do 
				"@#{user.username} @#{other_user.username} content that should change" 
			end
			it "should create links" do
				add_reply_links_to(content).should have_link user.username
				add_reply_links_to(content).should have_link other_user.username
			end
		end

		describe "content with invalid reply tags" do
			let(:content) { "@invalid_username content" }
			it "should not change" do
				add_reply_links_to(content).should eq "@invalid_username content"
			end
		end
	end
end