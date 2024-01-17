# frozen_string_literal: true

require 'test_helper'
require 'devise_gauth/controllers/helpers'

class HelpersTest < ActiveSupport::TestCase
  include DeviseGauth::Views::Helpers

  def setup
    @user = User.new(valid_attributes({ email: 'helpers_test@test.com' }))
  end

  test "can get username from user's email" do
    assert_equal 'helpers_test', username_from_email(@user.email)
  end

  test 'can get otpauth_user' do
    assert_equal 'username@app', otpauth_user('username', 'app')
  end

  test 'can get otpauth_user with a qualifier' do
    assert_equal 'username@app-qualifier', otpauth_user('username', 'app', '-qualifier')
  end

  # fake image tag
  def image_tag(src, *_)
    src
  end

  def qrcode_png(qualifier: nil, issuer: nil)
    build_qrcode_from(
      build_qrcode_data_from(
        'helpers_test',
        'RailsApp',
        @user.gauth_secret,
        qualifier,
        issuer
      )
    )
  end

  test 'generate qrcode' do
    assert_equal qrcode_png, google_authenticator_qrcode(@user)
    assert_equal qrcode_png(qualifier: 'MyQualifier'),
                 google_authenticator_qrcode(@user, 'MyQualifier')
    assert_equal qrcode_png(issuer: 'MyIssuer'),
                 google_authenticator_qrcode(@user, nil, 'MyIssuer')
    assert_equal qrcode_png(qualifier: 'MyQualifier', issuer: 'MyIssuer'),
                 google_authenticator_qrcode(@user, 'MyQualifier', 'MyIssuer')
  end
end
