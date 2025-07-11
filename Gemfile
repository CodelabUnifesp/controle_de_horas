source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.8', '>= 7.0.8.6'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'dotenv-rails'

gem 'vite_rails', '~> 3.0'

gem 'devise', '~> 4.9'
gem 'devise-jwt', '~> 0.12.1'
gem 'rack-cors', '~> 2.0'

gem 'kaminari'

group :development, :test do
  gem 'faker'
  gem 'foreman'
  gem 'rspec-rails'
end

group :development do
  gem 'annotate'
  gem 'lefthook', '~> 1.11'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'ruby-lsp'
  gem 'rufo', require: false
  gem 'solargraph'
  gem 'web-console'
end

group :test do
  gem 'factory_bot_rails'
  gem 'shoulda-matchers', '~> 5.0'
end
