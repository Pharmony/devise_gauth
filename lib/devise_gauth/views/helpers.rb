# frozen_string_literal: true

require 'rqrcode'
require 'base64'

module DeviseGauth
  module Views
    module Helpers
      def build_qrcode_data_from(username, app, gauth_secret, qualifier = nil, issuer = nil)
        data = "otpauth://totp/#{otpauth_user(username, app, qualifier)}"
        data += "?secret=#{gauth_secret}"
        data += "&issuer=#{issuer}" unless issuer.nil?
        data
      end

      def build_qrcode_from(data)
        qrcode = RQRCode::QRCode.new(data, level: :m, mode: :byte_8bit)
        png = qrcode.as_png(fill: 'white', color: 'black', border_modules: 1, module_px_size: 4)
        "data:image/png;base64,#{Base64.encode64(png.to_s).strip}"
      end

      def application_name_from(user)
        user.class.ga_appname || if Rails.version < '6'
                                   Rails.application.class.parent_name
                                 else
                                   Rails.application.class.module_parent_name
                                 end
      end

      def google_authenticator_qrcode(user, qualifier = nil, issuer = nil)
        data = build_qrcode_data_from(
          username_from_email(user.email),
          application_name_from(user),
          user.gauth_secret,
          qualifier,
          issuer
        )

        # data-uri is easier, so...
        image_tag(build_qrcode_from(data), alt: 'Google Authenticator QRCode')
      end

      def otpauth_user(username, app, qualifier = nil)
        "#{username}@#{app}#{qualifier}"
      end

      def username_from_email(email)
        /^(.*)@/.match(email)[1]
      end
    end
  end
end
