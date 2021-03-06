class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:fitbit_oauth2]

  has_many :identities, dependent: :destroy

  def self.from_omniauth(auth)
    identity = Identity.where(provider: auth.provider, uid: auth.uid).first_or_create do |identity|
      if identity.user.nil?
        user = User.new
        user.email = auth.info.email || "#{auth.uid}@example.org"
        user.password = Devise.friendly_token[0, 20]
      end
      identity.user = user
    end

    identity.access_token = auth["credentials"]["token"]
    identity.refresh_token = auth["credentials"]["refresh_token"]
    identity.expires_at = auth["credentials"]["expires_at"]
    identity.save
    identity.user
  end

  def identity_for(provider)
    identities.where(provider: provider).first
  end

  def fitbit_client
    fitbit_identity = identity_for("fitbit_oauth2")

    Fitbyte::Client.new(
      refresh_token: fitbit_identity.refresh_token,
      client_id: Rails.application.secrets.fitbyte_client_id,
      client_secret: Rails.application.secrets.fitbyte_client_secret,
      redirect_uri: "http://localhost:3000/users/auth/fitbit_oauth2/callback",
    )
  end
end
