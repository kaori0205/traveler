class PostsController < ApplicationController
  # 投稿を事前に探す処理
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    if @post.save
      redirect_to post_path(@post.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @posts = Post.published
    @posts = @posts.search(params[:search]) if params[:search].present?

    # 並び替えの条件分岐（デフォルト：新着順、パラメータがある場合：人気順）
  if params[:sort] == 'popular'
    @posts = @posts.popular
  else
    # デフォルトの新規投稿順（新しい順）
    @posts = @posts.order(created_at: :DESC)
  end

    @posts = @posts.page(params[:page])
  end

  def show
    @post.increment!(:view_count) # 閲覧数を増やす
    @comment = Comment.new
    @comments = @post.comments.page(params[:page]).per(7).reverse_order
  end

  def edit
    # ▼ 本人以外だったら、詳細ページや一覧ページにリダイレクトさせて止める！
    return unless @post.editable_by?(current_user) 
  end

  def update
    # ▼ 更新時も本人チェックを行う
    return unless @post.editable_by?(current_user)

    if @post.update(post_params)
      redirect_to post_path(@post.id)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # ▼ 削除時も本人チェックを行う
    return unless @post.editable_by?(current_user)

    @post.destroy
    redirect_to posts_path
  end

  def confirm
    @posts = current_user.posts.draft.page(params[:page]).reverse_order
  end

  private
  def post_params
    params.require(:post).permit(:user_id, :location, :text, :image, :status)
  end
  def set_post
    @post = Post.find(params[:id])
  end

end
