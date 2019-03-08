# frozen_string_literal: true

require 'devise/version'

class Devise::DisplayqrController < DeviseController
  if Rails.version >= '4'
    prepend_before_action :authenticate_scope!, only: %i[show update refresh]
  else
    prepend_before_filter :authenticate_scope!, only: %i[show update refresh]
  end

  include Devise::Controllers::Helpers

  # GET /resource/displayqr
  def show
    if resource.nil? || resource.gauth_secret.nil?
      sign_in resource_class.new, resource
      redirect_to stored_location_for(scope) || :root
    else
      @tmpid = resource.assign_tmp
      render :show
    end
  end

  def update
    if resource.gauth_tmp != params[resource_name]['tmpid'] || !resource.validate_token(params[resource_name]['gauth_token'].to_i)
      set_flash_message(:error, :invalid_token)
      render :show
      return
    end

    if resource.set_gauth_enabled(params[resource_name]['gauth_enabled'])
      set_flash_message :notice, (resource.gauth_enabled? ? :enabled : :disabled)
      if Gem::Version.new(Devise::VERSION) < Gem::Version.new('4.2.0')
        sign_in scope, resource, bypass: true
      else
        bypass_sign_in resource, scope: scope
      end

      respond_with resource, location: after_sign_in_path_for(resource)
    else
      render :show
    end
  end

  def refresh
    unless resource.nil?
      resource.send(:assign_auth_secret)
      resource.save
      set_flash_message :notice, :newtoken
      sign_in scope, resource, bypass: true
      redirect_to [resource_name, :displayqr]
    else
      redirect_to :root
    end
  end

  private

  def scope
    resource_name.to_sym
  end

  def authenticate_scope!
    # https://github.com/AsteriskLabs/devise_google_authenticator/issues/29
    send(:"authenticate_#{resource_name}!", force: true)
    self.resource = send("current_#{resource_name}")
  end

  # 7/2/15 - Unsure if this is used anymore - @xntrik
  def resource_params
    if strong_parameters_enabled?
      return params.require(resource_name.to_sym).permit(:gauth_enabled)
    end

    params
  end

  def strong_parameters_enabled?
    defined?(ActionController::StrongParameters)
  end
end
