class PostsController < ApplicationController
  # GET /post
  def index
    @posts = Post.where(published: true)
    render json: @posts, status: :ok
  end

  # GET /post/{id}
  def show
    @post = Post.find(params[:id])
    render json: @post, status: :ok
  end

  # POST /posts
  def create
    @post = Post.create!(create_params)
    render json: @post, status: :ok
  end

  # PUT /posts/{id}
  def update
    @post = Post.find(params[:id])
    @post.update!(update_params)
    render json: @post, status: :ok
  end

  # En rails se tiene que implementar los parametros que recibirán las rutas
  # de la siguiente manera
  private

  def create_params
    params.require(:post).permit(:title, :content, :published, :user_id)
  end

  def update_params
    params.require(:post).permit(:title, :content, :published)
  end
end