# frozen_string_literal: true

class User < PARENT_MODEL_CLASS
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :google_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  if Rails.version < '4'
    # Setup accessible (or protected) attributes for your model
    attr_accessible :gauth_enabled, :gauth_tmp, :gauth_tmp_datetime, :email, :password, :password_confirmation, :remember_me
  end
end
