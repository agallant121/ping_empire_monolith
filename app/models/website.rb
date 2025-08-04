class Website < ApplicationRecord
  belongs_to :user

  has_many :responses, dependent: :destroy

  validates :url, presence: true, uniqueness: true
end
