require 'rails_helper'

# 課題：このテストがすべて通るように、app/models/post.rb にメソッドを追加してください。
# テストのファイルは書き換えないでください。

RSpec.describe Post, type: :model do
  # テスト用のユーザーと投稿を作る（画像の検証を通さずに保存するため validate: false を使っています）
  let(:user)  { User.create!(name: '山田', email: 'yamada@example.com', password: 'password') }
  let(:other) { User.create!(name: '佐藤', email: 'sato@example.com', password: 'password') }

  def create_post(location:, text:, user:, created_at: Time.current)
    post = Post.new(location: location, text: text, user: user, created_at: created_at)
    post.save!(validate: false)
    post
  end

  describe '.search（キーワード検索）' do
    let!(:kyoto)   { create_post(location: '京都', text: '清水寺に行きました', user: user) }
    let!(:okinawa) { create_post(location: '沖縄', text: '海がきれいでした', user: user) }
    let!(:nara)    { create_post(location: '奈良', text: '京都から電車で移動', user: other) }

    it '場所（location）にキーワードを含む投稿が見つかる' do
      expect(Post.search('沖縄')).to contain_exactly(okinawa)
    end

    it '本文（text）にキーワードを含む投稿も見つかる' do
      expect(Post.search('京都')).to contain_exactly(kyoto, nara)
    end

    it 'キーワードの一部だけでも見つかる（部分一致）' do
      expect(Post.search('清水')).to contain_exactly(kyoto)
    end

    it 'キーワードが空のときは、すべての投稿を返す' do
      expect(Post.search('')).to contain_exactly(kyoto, okinawa, nara)
      expect(Post.search(nil)).to contain_exactly(kyoto, okinawa, nara)
    end

    it '当てはまる投稿がないときは、空になる' do
      expect(Post.search('北海道')).to be_empty
    end
  end

  describe '.popular（いいねが多い順）' do
    let!(:old_post) { create_post(location: '大阪', text: 'たこ焼き', user: user, created_at: 3.days.ago) }
    let!(:mid_post) { create_post(location: '福岡', text: 'ラーメン', user: user, created_at: 2.days.ago) }
    let!(:new_post) { create_post(location: '札幌', text: '時計台', user: user, created_at: 1.day.ago) }

    before do
      Favorite.create!(user: user, post: mid_post)
      Favorite.create!(user: other, post: mid_post)
      Favorite.create!(user: user, post: old_post)
    end

    it 'いいねの数が多い順に並ぶ' do
      expect(Post.popular.first).to eq mid_post
    end

    it 'いいねの数が同じときは、新しい投稿が先に来る' do
      Favorite.create!(user: other, post: new_post)
      expect(Post.popular.to_a).to eq [mid_post, new_post, old_post]
    end

    it 'いいねが0件の投稿も含まれる' do
      expect(Post.popular.to_a.size).to eq 3
    end
  end

  describe '#excerpt（本文の抜粋）' do
    it '本文が20文字より長いときは、先頭20文字のあとに「…」を付ける' do
      post = Post.new(text: 'あ' * 25)
      expect(post.excerpt).to eq "#{'あ' * 20}…"
    end

    it '本文が20文字以下のときは、そのまま返す' do
      post = Post.new(text: '短い本文')
      expect(post.excerpt).to eq '短い本文'
    end

    it '文字数を指定できる' do
      post = Post.new(text: 'あいうえおかきくけこ')
      expect(post.excerpt(5)).to eq 'あいうえお…'
    end
  end

  describe '#editable_by?（編集してよいか）' do
    let(:post) { create_post(location: '神戸', text: '夜景', user: user) }

    it '投稿したユーザー本人なら true' do
      expect(post.editable_by?(user)).to be true
    end

    it 'ほかのユーザーなら false' do
      expect(post.editable_by?(other)).to be false
    end

    it 'ログインしていない（nil）なら false' do
      expect(post.editable_by?(nil)).to be false
    end
  end
end