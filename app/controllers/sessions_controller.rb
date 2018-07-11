class SessionsController < ApplicationController

  # GET: /sessions/new
  get "/login" do
    erb :"/sessions/new.html"
  end

  # POST: /sessions
  post "/sessions" do
    @user = User.find_by(email: params[:user][:email])
    if @user && @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id
      redirect "/posts"
    else
      flash.now[:error] = "Whoops! Try again."
      erb :"/sessions/new.html"
    end
  end

  # DELETE: /sessions/5/delete
  get "/logout" do
    session[:user_id] = nil
    redirect "/posts"
  end
end
