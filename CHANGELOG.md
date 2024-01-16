# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Renames the gem as `devise_gauth`
- Uses Ruby to generate QRCode images instead of using Google APIs

### Fixed
- Rails 5.x and 6.x compatiblites

## [0.3.16] - 2015-02-08
- A few bug-fixes. Test-cases are now passing in Ruby 1.9.3 and 2.1.5

## [0.3.15] - 2014-09-11
Can now configure whether the displayqr page is displayed during sign-up. Can customise the app's name (thanks Felipe Lima). Require the users to enter the token when enabling or disabling the token (thanks again Felipe Lima). Handle namespaced Devise models (thanks Mikkel Garcia). Ability to set an Issuer within the OTP generation (thanks Sylvain UTARD).

## [0.3.14] - 2014-03-29
Users can now generate a new token if they wish. This is available from the displayqr page.

## [0.3.13] - 2014-03-28
Merged a feature to allow a qualifier for the Google Authenticator token display. This allows you to specify in your view a qualifier for the name of the OTP when it's enrolled into the Google Authenticator app. Thanks Michael Guymon for the pull.

## [0.3.12] - 2014-03-28
Re-introduced Warden's after_authentication callback. Thanks Sunny Ng for the pull.

## [0.3.11] - 2014-03-28
Fixed a bug where if the Devise module was included within something else, such as Active Admin, rewriting back to the CheckGA functionality was broken. This update addresses https://github.com/AsteriskLabs/devise_google_authenticator/issues/7

## [0.3.10] - 2014-03-20
Added support for Mongoid ORM in addition to ActiveRecord. (Still no appropriate testing for, but I've run this on vanilla Rails 4.0.4 and Devise 3.2.3 apps)

## [0.3.9] - 2014-03-16
Merging fix from zhenyuchen (deprecated ActiveRecord query grammar) - also, re-tested against Rails 4.0.4 and Devise 3.2.3

## [0.3.8] - 2013-12-29
Support for remembering the token authentication. (i.e. don't request the token for a configurable amount of time Thanks https://github.com/blahblahblah-) - and seriously, I'm going to try and refactor all the integration tests with Rspec.

## [0.3.7] - 2013-12-29
Support for current Devise (3.2.0) and Rails4 (Thanks https://github.com/ronald05arias) - integration test still broke - need to address this

## [0.3.6] - 2013-08-13
Slight updates - increased key size, more open gemspec, updated en.yml. (Thanks Michael Guymon)

## [0.3.5] - 2013-07-02
Updated README for Rails apps with existing users. (Thanks Jon Collier)

## [0.3.4] - 2013-07-02
Updated test cases to function properly, and tested working with Devise 2.2 (up to at least Devise 2.2.4)

## [0.3.3] - 2012-05-27
Updated some of the redirect methods to proper align with Devise 2.1.0. Also tidied up some of the test routines to proper replicate Devise 2.1.0

## [0.3.2] - 2012-04-06
Updated to include support for Devise 2.0.0 and above (no longer supports 1.5.3 or lower), you'll need version 0.3.1 to use older Devise

## [0.3.1] - 2012-01-29
Slight updated in the dependencies.

## [0.3.0] - 2012-01-29
first working version! With working generators, tests, and doesnt require changes to Devise's Sign In view

## [0.2.0] - 2011-11-22
tidied up some of the code - changed the references to AsteriskLabs

## [0.1.0] - 2011-11-21
initial release, just to push it up, is still very early and requires a bit work

[Unreleased]: https://github.com/pharmony/devise_gauth/compare/v0.3.16...master
[0.3.16]: https://github.com/pharmony/devise_gauth/compare/v0.3.15...v0.3.16
[0.3.15]: https://github.com/pharmony/devise_gauth/compare/v0.3.14...v0.3.15
[0.3.14]: https://github.com/pharmony/devise_gauth/compare/v0.3.13...v0.3.14
[0.3.13]: https://github.com/pharmony/devise_gauth/compare/v0.3.12...v0.3.13
[0.3.12]: https://github.com/pharmony/devise_gauth/compare/v0.3.11...v0.3.12
[0.3.11]: https://github.com/pharmony/devise_gauth/compare/v0.3.10...v0.3.11
[0.3.10]: https://github.com/pharmony/devise_gauth/compare/v0.3.9...v0.3.10
[0.3.9]: https://github.com/pharmony/devise_gauth/compare/v0.3.8...v0.3.9
[0.3.8]: https://github.com/pharmony/devise_gauth/compare/v0.3.7...v0.3.8
[0.3.7]: https://github.com/pharmony/devise_gauth/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/pharmony/devise_gauth/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/pharmony/devise_gauth/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/pharmony/devise_gauth/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/pharmony/devise_gauth/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/pharmony/devise_gauth/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/pharmony/devise_gauth/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/pharmony/devise_gauth/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/pharmony/devise_gauth/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/Pharmony/devise_gauth/tree/v0.1.0
