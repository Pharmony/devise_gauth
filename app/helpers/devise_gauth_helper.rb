# frozen_string_literal: true

module DeviseGauthHelper
  DEVISE_VERSION = Gem::Version.new(Gem::Specification.find_by_name('devise').version)

  def devise_4_6_and_above?
    Gem::Version.new('4.6.0') <= DEVISE_VERSION
  end
end
