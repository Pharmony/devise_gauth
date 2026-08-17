# frozen_string_literal: true

require_relative 'lib/devise_gauth/version'

Gem::Specification.new do |spec|
  spec.name = 'devise_gauth'
  spec.version = DeviseGauth::VERSION
  spec.authors = ['Pharmony SA']
  spec.email = ['dev@pharmony.eu']

  spec.summary = 'Maintained Devise Google Authenticator Extension'
  spec.description = 'Devise Google Authenticator Extension, for adding ' \
                     "Google's OTP to your Rails apps!"
  spec.homepage = 'http://github.com/pharmony/devise_gauth'
  spec.license = 'MIT'

  spec.required_ruby_version = if ENV.fetch('PUBLISHING_GEM', false)
                                 ['>= 2.4', '<= 3.4']
                               else
                                 ">= #{ENV.fetch('EARTHLY_RUBY_VERSION')}"
                               end

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['{app,config,lib}/**/*'] + %w[LICENSE.txt README.md]
  spec.require_paths = ['lib']

  if ENV.fetch('PUBLISHING_GEM', false)
    spec.add_dependency 'actionmailer', '>= 4.2', '<= 8.0'
    spec.add_dependency 'devise'
    spec.add_dependency 'railties', '>= 4.2', '<= 8.0'
  else
    devise_version = ENV.fetch('EARTHLY_DEVISE_VERSION')
    rails_min_version = ENV.fetch('EARTHLY_RAILS_VERSION')

    spec.add_dependency 'actionmailer', "~> #{rails_min_version}"
    spec.add_dependency 'devise', "~> #{devise_version}"
    spec.add_dependency 'railties', "~> #{rails_min_version}"
  end

  spec.add_dependency 'rotp', '~> 2.1'
  spec.add_dependency 'rqrcode', '~> 2.1.2'
end
