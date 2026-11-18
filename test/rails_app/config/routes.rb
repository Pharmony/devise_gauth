# frozen_string_literal: true

# Devise 4.9 passes the `devise_registration` route options to `resource` as a
# positional Hash (`resource :registration, options`), which Rails 8.1
# deprecates ("resource received a hash argument ...", removed in Rails 8.2).
# Devise 5.0 fixed this by splatting the options as keywords. Re-apply that
# upstream fix here, only while running Devise < 5 on Rails >= 8.1, so that
# `devise_for :users` below does not emit the deprecation warning.
#
# `Devise::VERSION` cannot be used here: this file is first evaluated from
# Devise's own `before_eager_load` hook (`app.reload_routes!` in
# devise/rails.rb), before anything has required `devise/version`. Read the
# version from the activated gem specification instead.
devise_version = Gem.loaded_specs['devise']&.version

# The file is evaluated more than once per boot (the reload above, then the
# real draw), so define the module only once to avoid `method redefined`
# warnings when running the suite under `ruby -w`.
if Gem::Version.new(Rails.version) >= Gem::Version.new('8.1') &&
   devise_version && devise_version < Gem::Version.new('5') &&
   !defined?(DeviseRegistrationResourceKeywords)
  module DeviseRegistrationResourceKeywords
    # Identical to Devise 4.9's implementation, except the options Hash is
    # splatted as keywords to `resource`.
    # rubocop:disable Metrics/MethodLength
    def devise_registration(mapping, controllers)
      path_names = {
        new: mapping.path_names[:sign_up],
        edit: mapping.path_names[:edit],
        cancel: mapping.path_names[:cancel]
      }

      options = {
        only: %i[new create edit update destroy],
        path: mapping.path_names[:registration],
        path_names: path_names,
        controller: controllers[:registrations]
      }

      resource :registration, **options do
        get :cancel
      end
    end
    # rubocop:enable Metrics/MethodLength
  end

  ActionDispatch::Routing::Mapper.prepend(DeviseRegistrationResourceKeywords)
end

RailsApp::Application.routes.draw do
  devise_for :users

  resources :posts
  root to: 'posts#index'
end
