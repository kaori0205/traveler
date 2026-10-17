class Post < ApplicationRecord

    has_one_attached :image
    belongs_to :user
    has_many :comments, dependent: :destroy
    has_many :favorites, dependent: :destroy

  validates :location, presence: true, length: { maximum: 15 }
  validates :text, presence: true, length: { maximum: 195 }
  validates :image, presence: true

  enum :status, { published: 0, draft: 1 }

  def favorited_by?(user)
    favorites.where(user_id: user.id).exists?
  end

  def self.search(keyword)
    if keyword.present?
      where('location LIKE ? OR text LIKE ?', "%#{keyword}%", "%#{keyword}%")
    else
      all
    end
  end

  def self.popular
    left_joins(:favorites)
      .group(:id)
      .order(Arel.sql('COUNT(favorites.id) DESC, posts.created_at DESC'))
  end

  def excerpt(length = 20)
    text.length > length ? "#{text[0, length]}…" : text
  end

  def editable_by?(user)
    user.present? && self.user_id == user.id
  end
end