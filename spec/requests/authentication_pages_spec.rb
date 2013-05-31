require 'spec_helper'

describe "AuthenticationPages" do

	subject { page }

    describe "signin page" do
        before { visit signin_path }

        let(:signin) { "Sign in" }

        it { should have_content('Sign in') }
        it { should have_title('Sign in') }

        describe "with invalid information" do
            before { click_button signin }

            it { should have_title('Sign in') }
            it { should have_error_message('Invalid') }

            describe "after visiting another page" do
                before { click_link "Home" }
                it { should_not have_error_message('Invalid') }

            end
        end

        describe "with valid information" do
            let(:user) { FactoryGirl.create(:user) }
            before { valid_signin(user) }

            it { should have_title user.name }
            it { should have_link 'Users', href: users_path }
            it { should have_link 'Profile', href: user_path(user) }
            it { should have_link 'Sign out', href: signout_path }
            it { should_not have_link 'Sign in', href: signin_path }


            describe "followed by signout" do
                before { click_link 'Sign out' }
                it { should have_link 'Sign in'}
                it { should_not have_link 'Profile', href: user_path(user) }
                it { should_not have_link 'Settings', href: edit_user_path(user) }
            end
        end
    end

    describe "authorization" do

        describe "for non-signed-in users" do
            let(:user) { FactoryGirl.create(:user) }

            describe "when attempting to visit a protected page" do
                before do
                    visit edit_user_path(user)
                    valid_signin(user)
                end

                describe "after signing in" do

                    it "should render the desired protected page" do
                        expect(page).to have_title('Edit user')
                    end

                    describe "and then signing in again" do
                        before do
                            # delete signout_path
                            sign_in(user)
                        end

                        it { should have_title user.name }
                    end
                end
            end
            describe "in the Users controller" do

                describe "visiting the edit page" do
                    before { visit edit_user_path(user) }
                    it { should have_title('Sign in') }
                end

                describe "submitting to the update action" do
                    before { patch user_path(user) }
                    specify { expect(response).to redirect_to(signin_path) }
                end

                describe "visiting the user index" do
                    before { visit users_path }
                    it { should have_title('Sign in') }
                end
            end
            describe "in the Microposts controller" do
                describe "posting a Micropost" do
                    before { post microposts_path }
                    specify { expect(response).to redirect_to(signin_path) }
                end
                describe "deleting a Micropost" do
                    before { delete micropost_path(FactoryGirl.create(:micropost)) }
                    specify { expect(response).to redirect_to(signin_path) }
                end
                    
            end
        end

        describe "as wrong user" do
            let(:user) { FactoryGirl.create(:user) }
            let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
            before { sign_in user }

            describe "visiting Users#edit page" do
                before { visit edit_user_path(wrong_user) }
                it { should_not have_title(full_title('Edit user')) }
            end

            describe "submitting a PATCH request to the Users#update action" do
                before { patch user_path(wrong_user) }
                specify { expect(response).to redirect_to(root_path) }
            end
        end

        describe "as non-admin user" do
            let(:user) { FactoryGirl.create(:user) }
            let(:non_admin) { FactoryGirl.create(:user) }

            before { sign_in non_admin }

            describe "submitting a DELETE request to the Users#destroy action" do
                before { delete user_path(user) }
                specify { expect(response).to redirect_to(root_path) }
            end
        end

        describe "as signed-in user" do
            let(:user) { FactoryGirl.create(:user) }

            before { sign_in user }

            describe "visiting sign up page" do
                before { visit signup_path }

                it { should_not have_title('Sign Up') }
            end

            describe "submitting a CREATE request to the Users#create action" do
                before { post users_path(user: { 
                    name: user.name, 
                    email: user.email, 
                    password: user.password, 
                    password_confirmation: user.password_confirmation } ) }
                specify { expect(response).to redirect_to(root_path) }
            end
        end

        describe "as admin user" do
            let(:admin) { FactoryGirl.create(:admin) }
            before { sign_in admin }

            describe "submitting a DELETE request on themself" do
                
                specify { expect { delete user_path(admin) }.not_to change(User, :count) }
            end
        end
    end
end
