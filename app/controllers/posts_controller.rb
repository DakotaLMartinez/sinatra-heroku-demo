class PostsController < ApplicationController

  # GET: /posts
  get "/posts" do
    @posts = Post.all
    erb :"/posts/index.html"
  end

  # GET: /posts/new
  get "/posts/new" do
    ensure_logged_in
    erb :"/posts/new.html"
  end

  # POST: /posts
  post "/posts" do
    ensure_logged_in
    if current_user.posts.create(params[:post])
      redirect "/posts"
    else
      erb "/posts/new.html"
    end
  end

  # GET: /posts/5
  get "/posts/:id" do
    if @post = Post.find_by(id: params[:id])
      erb :"/posts/show.html"
    else
      flash[:error] = "Couldn't find that post"
      redirect "/posts"
    end
  end

  # GET: /posts/5/edit
  get "/posts/:id/edit" do
    erb :"/posts/edit.html"
  end

  # PATCH: /posts/5
  patch "/posts/:id" do
    redirect "/posts/:id"
  end

  # DELETE: /posts/5/delete
  delete "/posts/:id/delete" do
    redirect "/posts"
  end
end
