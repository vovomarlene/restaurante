class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { caixa: 0, admin: 1 }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
