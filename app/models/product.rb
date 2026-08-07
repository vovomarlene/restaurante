class Product < ApplicationRecord
  belongs_to :category

  has_many :recipe_items, dependent: :destroy
  has_many :ingredients, through: :recipe_items
  has_many :order_items, dependent: :restrict_with_error

  accepts_nested_attributes_for :recipe_items, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
end
