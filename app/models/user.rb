class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2, :facebook, :twitter2 ]

  has_many :websites, dependent: :destroy

  ROLES = { user: 0, admin: 1 }.freeze
  LANGUAGE_OPTIONS = %w[en es fr].freeze

  scope :admins, -> { where(role: 1) }
  scope :regular_users, -> { where(role: 0) }

  before_validation :set_default_language
  validates :preferred_language, inclusion: { in: LANGUAGE_OPTIONS }

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first

    unless user
      user = find_by(email: auth.info.email)

      if user
        user.update(provider: auth.provider, uid: auth.uid)
      else
        user = create(
          provider: auth.provider,
          uid: auth.uid,
          email: auth.info.email,
          password: Devise.friendly_token[0, 20]
        )
      end
    end

    user
  end

  def website_count
    @website_count ||= websites.count
  end

  def admin?
    role == 1
  end

  def regular_user?
    role == 0
  end

  private

  def set_default_language
    self.preferred_language ||= I18n.default_locale.to_s
  end
end
