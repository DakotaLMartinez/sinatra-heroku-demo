source 'http://rubygems.org'

ruby '2.5.3'

gem 'sinatra'
gem 'activerecord', '5.2.8.1', :require => 'active_record'
gem 'sinatra-activerecord', :require => 'sinatra/activerecord'
gem 'pg', '0.20'
gem 'dotenv'
gem 'foreman'
gem 'rails_12factor'
gem 'rake'
gem 'require_all'
gem 'thin'
gem 'sysrandom'
gem 'sinatra-flash'
gem 'bcrypt'

group :development do 
  gem 'sqlite3', '<1.4'
  gem 'shotgun'
  gem 'tux'
  gem 'pry'

end

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test'
  gem 'database_cleaner', git: 'https://github.com/bmabey/database_cleaner.git'
end
