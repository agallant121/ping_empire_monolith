class Website < ApplicationRecord
  has_many :responses, dependent: :destroy
  validates :url, presence: true, uniqueness: true
end
