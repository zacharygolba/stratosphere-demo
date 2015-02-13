class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.with_image.page(params[:page])
    render 'posts/_posts', layout: false if request.xhr?
  end

  def show
    redirect_to posts_path unless @post.image.exists?
  end

  def edit
  end

  def create
    @post = Post.create!(post_params)
    render json: { id: @post.id }
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy
    head :ok
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title)
    end
end
