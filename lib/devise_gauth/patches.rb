# frozen_string_literal: true

module DeviseGauth
  module Patches
    autoload :DisplayQR, 'devise_gauth/patches/display_qr'

    class << self
      def apply
        Devise::RegistrationsController.send(:include, Patches::DisplayQR)
      end
    end
  end
end
