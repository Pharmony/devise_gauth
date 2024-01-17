# frozen_string_literal: true

require 'devise_gauth/controllers/helpers'

module DeviseGauth
  class Engine < ::Rails::Engine
    if Rails.version > '5'
      ActiveSupport::Reloader.to_prepare do
        DeviseGauth::Patches.apply
      end
    else
      ActionDispatch::Callbacks.to_prepare do
        DeviseGauth::Patches.apply
      end
    end

    ActiveSupport.on_load(:action_controller) do
      include DeviseGauth::Controllers::Helpers
    end
  end
end
