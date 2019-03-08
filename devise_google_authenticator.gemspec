# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name = 'devise_google_authenticator'
  s.version = '0.3.16'
  s.authors = ['Christian Frichot']
  s.date = '2015-02-08'
  s.description = 'Devise Google Authenticator Extension, for adding ' \
                  "Google's OTP to your Rails apps!"
  s.email = 'xntrik@gmail.com'
  s.extra_rdoc_files = [
    'LICENSE.txt',
    'README.rdoc'
  ]
  s.files = Dir['{app,config,lib}/**/*'] + %w[LICENSE.txt README.rdoc]
  s.homepage = 'http://github.com/AsteriskLabs/devise_google_authenticator'
  s.licenses = ['MIT']
  s.require_paths = ['lib']
  s.summary = 'Devise Google Authenticator Extension'

  ruby_version = ENV.fetch('EARTHLY_RUBY_VERSION', '3.0')
  s.required_ruby_version = ">= #{ruby_version}"

  devise_version = ENV.fetch('EARTHLY_DEVISE_VERSION', '4.6')
  rails_min_version = ENV.fetch('EARTHLY_RAILS_VERSION', '6.1.6')
  rails_max_version = (rails_min_version.split('.').first.to_i + 1).to_s

  puts "Building gem dependencies using Rails '~> #{rails_min_version}', " \
       "'< #{rails_max_version}' and devise '~> #{devise_version}' with Ruby " \
       "'>= #{ruby_version}' (Current version: #{RUBY_VERSION}) ..."

  s.add_runtime_dependency 'actionmailer', "~> #{rails_min_version}",
                                           "< #{rails_max_version}"
  s.add_runtime_dependency 'devise', "~> #{devise_version}"
  s.add_runtime_dependency 'railties', "~> #{rails_min_version}",
                                       "< #{rails_max_version}"
  s.add_runtime_dependency 'rotp', '~> 1.6'
end
