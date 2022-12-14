class Public::PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_current_user, only: [:edit, :update,:destroy]
  before_action :edit_current_user, only: [:map_edit]
  before_action :post_choice, only: [:show, :map_edit, :update, :destroy]

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
   if @post.user_id = current_user.id
     if @post.save
       redirect_to post_path(@post),notice: ((@post.is_draft == "draft") ? "マイページの下書き投稿に保存しました。" : "投稿しました。")
     else
       redirect_to new_post_path(@post), alert: "入力内容をご確認ください。"
     end
   end
  end

  def index
    @post = Post.new
    @posts = params[:shop_tag_ids].present? ? ShopTag.find(params[:shop_tag_ids]).posts.page(params[:page]) : Post.published.order(created_at: :desc).page(params[:page]).per(6)
  end

  def show
    @post = Post.find(params[:id])
    @comment = Comment.new
    @shop_tags = @post.tags
    @user_post =@post.user
  end

  def map_edit
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if current_user == @post.user
      if @post.update(post_params)
          redirect_to post_path(@post),notice: ((@post.is_draft == "draft") ? "マイページの下書き投稿に保存しました。" : "更新しました。")
      else
        redirect_to edit_post_path(@post), alert: "編集内容をご確認ください。"
      end
    else
      redirect_to posts_path, alert: "本人以外更新できません。"
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if current_user == @post.user
      @post.destroy
      redirect_to posts_path, notice: "投稿を削除しました。"
    else
      redirect_to posts_path, alert: "本人以外は投稿を削除できません。"
    end
  end

#下書き投稿ページ
  def draft_index
    @posts = current_user.posts.draft.reverse_order
  end

   # こだわりタグ検索結果ページ
  def shop_tag
    @shop_tag = ShopTag.find_by(name: params[:name])
    @post = @shop_tag.posts.page(params[:page])


  end
  # タグ検索結果ページ
  def tag
    @tag = Tag.find_by(name: params[:name])
    @post = @tag.posts.page(params[:page])
  end

  def post_choice
    if (params[:id]).present?
      @post = Post.find(params[:id])
    else
      @post = Post.find(params[:post_id])
    end
  end


  private
  def post_params
  params.require(:post).permit(:user_id, :title, :content, :shop_name, :shop_place, :shop_holiday, :shop_price, :is_draft, :image, :lat, :lng, shop_tag_ids:[])
  end

  def ensure_current_user
    @post = Post.find(params[:id])
    unless @post.user == current_user
      redirect_to posts_path
    end
  end
  
  def edit_current_user
    @post = Post.find(params[:post_id])
    unless @post.user == current_user
      redirect_to posts_path
    end
  end
  
end