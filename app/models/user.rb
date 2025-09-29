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
end
