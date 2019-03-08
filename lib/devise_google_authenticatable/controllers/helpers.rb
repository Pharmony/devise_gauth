# frozen_string_literal: true

module DeviseGoogleAuthenticator
  module Controllers # :nodoc:
    module Helpers # :nodoc:
      extend ActiveSupport::Concern

      included do
        if Rails.version >= '4'
          before_action :check_request_and_redirect_to_check_totp,
                         if: :user_signing_in?
        else
          before_filter :check_request_and_redirect_to_check_totp,
                         if: :user_signing_in?
        end

        define_method :checkga_resource_path_name do |resource, id|
          name = resource.class.name.singularize.underscore
          name = name.split('/').last
          "#{name}_checkga_path(id:'#{id}')"
        end
      end

      private

      def devise_sessions_controller?
        instance_of?(Devise::SessionsController) ||
          self.class.ancestors.include?(Devise::SessionsController)
      end

      def user_signing_in?
        if devise_controller? && signed_in?(resource_name) &&
           devise_sessions_controller? &&
           action_name == 'create'
          return true
        end

        false
      end

      def check_request_and_redirect_to_check_totp
        # User successfully signed in AND has enabled 2FA
        if signed_in?(resource_name) &&
           warden.session(resource_name)[:with_totp_authentication]

          resource = warden.authenticate!(auth_options)

          # The user has 2FA and token has expired
          if resource.respond_to?(:get_qr) && resource.require_token?(cookies.signed[:gauth])

            tmpid = resource.assign_tmp # Assign a temporary key and fetch it
            warden.logout # log the user out

            # We head back into the checkga controller with the temporary id
            # Because the model used for google auth may not always be the same,
            # and may be a sub-model, the eval will evaluate the appropriate path
            # name
            # This change addresses https://github.com/AsteriskLabs/devise_google_authenticator/issues/7
            respond_with resource,
                         location: eval(checkga_resource_path_name(resource,
                                                                   tmpid))
          # User is not using, OR not enabled for Google 2FA, OR is remembering
          # token and therefore not asking for the moment
          # carry on, nothing to see here.
          else
            respond_with resource, location: after_sign_in_path_for(resource)
          end
        end
      end
    end
  end
end
