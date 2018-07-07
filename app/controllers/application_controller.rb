require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    use Rack::Session::Cookie, :key => 'rack.session',
                               :path => '/',
                               :secret => ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  end

  get "/" do
    erb :welcome
  end

  helpers do 

    def current_user
      session[:user_id] && User.find_by(id: session[:user_id])
    end

    def test
      "hello"
    end

    def logged_in?
      !!current_user
    end
  end

end
