ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])
Dotenv.load
require 'sysrandom/securerandom'

set :database_file, "./database.yml"

require_all 'app'
