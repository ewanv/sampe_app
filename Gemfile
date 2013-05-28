source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '4.0.0.rc1'
gem 'bootstrap-sass', '2.3.1.0'
gem 'bcrypt-ruby', '3.0.1'

group :development, :test do
  	gem 'sqlite3', '1.3.7'
  	gem 'rspec-rails', '2.13.1'
  	gem 'guard-rspec', '2.5.0'
    gem 'spork-rails', github: 'railstutorial/spork-rails'
  	gem 'childprocess', '0.3.6'
  	gem 'guard-spork', '1.5.0'
end

group :development do
  gem 'annotate', '2.5.0'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
 	gem 'sass-rails',   '4.0.0.rc1'
	gem 'coffee-rails', '4.0.0'
	gem 'uglifier', '2.1.1'
end

gem 'jquery-rails', '2.2.1'
gem 'turbolinks', '1.1.1'
gem 'jbuilder', '1.0.2'

group :test do
  gem 'selenium-webdriver', '2.0.0'
	gem 'capybara', '2.1.0'
	gem 'rb-fsevent', '0.9.1', :require => false
  gem 'growl', '1.0.3'
  gem 'factory_girl_rails', '4.2.1'
end

group :doc do
  gem 'sdoc', '0.3.20', require: false
end

group :production do
   	gem 'pg', '0.15.1'
end

