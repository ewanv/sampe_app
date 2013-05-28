FactoryGirl.define do
	factory :user do
		name		"Ewan Vaughan"
		email		"evaughan@example.com"
		password	"foobar"
		password_confirmation "foobar"
	end 
end