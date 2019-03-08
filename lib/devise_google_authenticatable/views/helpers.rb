# frozen_string_literal: true

module DeviseGoogleAuthenticator
  module Views
    module Helpers
      def google_authenticator_qrcode(user, qualifier=nil, issuer=nil)
        username = username_from_email(user.email)
        app = user.class.ga_appname || if Rails.version < '6'
                                         Rails.application.class.parent_name
                                       else
                                         Rails.application.class.module_parent_name
                                       end
        data = "otpauth://totp/#{otpauth_user(username, app, qualifier)}?secret=#{user.gauth_secret}"
        data += "&issuer=#{issuer}" unless issuer.nil?
        data = Rack::Utils.escape(data)
        url = "https://chart.googleapis.com/chart?chs=200x200&chld=M|0&cht=qr&chl=#{data}"
        image_tag(url, alt: 'Google Authenticator QRCode')
      end

      def otpauth_user(username, app, qualifier=nil)
        "#{username}@#{app}#{qualifier}"
      end

      def username_from_email(email)
        (/^(.*)@/).match(email)[1]
      end
    end
  end
end
