require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    register Sinatra::Flash
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET') 
  end

  get "/" do
    redirect "/posts"
  end

  helpers do 

    def current_user
      puts session.inspect
      session[:user_id] && User.find_by(id: session[:user_id])
    end

    def logged_in?
      !!current_user
    end

    def ensure_logged_in
      unless logged_in?
        flash[:error] = "You must be logged in to view this page."
        redirect "/login"
      end
    end
  end

end
