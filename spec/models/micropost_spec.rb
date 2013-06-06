require 'spec_helper'

describe Micropost do

	let(:user) { FactoryGirl.create(:user) }
	before { @micropost = user.microposts.build(content:"Lorem ipsum") }

	subject { @micropost }

	it { should respond_to :content }
	it { should respond_to :user_id }
	it { should respond_to :user }
	it { should respond_to :in_reply_to_users }
	it { should respond_to :reply? }
	its(:user) { should eq user }

	it { should be_valid }
	it { should_not be_reply }

	describe "when user_id is not present" do
		before { @micropost.user_id = nil }
		it { should_not be_valid }
	end

	describe "with blank content" do
		before { @micropost.content = " " }
		it { should_not be_valid }
	end

	describe "with content that is too long" do
		before { @micropost.content = "a" * 141 }
		it { should_not be_valid }
	end

	describe "with reply tag" do
		let(:other_user) { FactoryGirl.create(:user) }
		before do
			@micropost.content = "@#{other_user.username} Reply!"
			@micropost.save
		end
		it { should be_reply }
		specify { expect { @micropost.in_reply_to_users.exists?(other_user)}.to be_true }
	end
end
