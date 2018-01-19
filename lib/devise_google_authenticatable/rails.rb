module DeviseGoogleAuthenticator
  class Engine < ::Rails::Engine # :nodoc:
    if Rails.version > '5'
      ActiveSupport::Reloader.to_prepare do
        DeviseGoogleAuthenticator::Patches.apply
      end
    else
      ActionDispatch::Callbacks.to_prepare do
        DeviseGoogleAuthenticator::Patches.apply
      end
    end

    ActiveSupport.on_load(:action_controller) do
      include DeviseGoogleAuthenticator::Controllers::Helpers
    end
  end
end
