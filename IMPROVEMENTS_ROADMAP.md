# Devise Google Authenticator – Improvements & Ruby 4 Readiness Roadmap

This document outlines a staged implementation plan to address security, compatibility, refactoring, and modernization concerns in the `devise_gauth` gem.

---

## Stage 1: Critical Security & Correctness Fixes

These changes address security vulnerabilities and data correctness issues that should be fixed first.

- [ ] **1.1 Clear TOTP challenge after successful validation**
  - **File:** `app/controllers/devise/checkga_controller.rb`
  - **Issue:** After a successful token check, `gauth_tmp` and `gauth_tmp_datetime` remain valid until timeout, allowing potential replay attacks.
  - **Implementation:**
    - Modify the success path in the `update` action to atomically clear `gauth_tmp` and `gauth_tmp_datetime`.
    - Example: `resource.update(gauth_tmp: nil, gauth_tmp_datetime: nil)` after `sign_in`.
  - **Tests:** Verify the temporary challenge is cleared and cannot be reused.

- [ ] **1.2 Eliminate token coercion with `to_i`**
  - **Files:**
    - `app/controllers/devise/checkga_controller.rb` (line 28)
    - `app/controllers/devise/displayqr_controller.rb` (line 26)
    - `lib/devise_gauth/models/google_authenticatable.rb` (lines 45–55)
  - **Issue:** Inputs like `"abc"` are coerced to `0`, causing semantic errors and potential validation confusion.
  - **Implementation:**
    - Add validation before passing token to ROTP:
      ```ruby
      token = params.dig(resource_name, 'gauth_token').to_s.strip
      return invalid_token_response unless token.match?(/\A\d{6}\z/)
      ```
    - Pass the validated string to `validate_token` instead of converting to integer.
  - **Tests:** Reject non-numeric tokens, empty tokens, and malformed input; verify only 6-digit codes are accepted.

- [ ] **1.3 Implement OTP rate limiting and failure counter**
  - **File:** `app/controllers/devise/checkga_controller.rb`
  - **Issue:** No rate limiting on token validation attempts allows online brute-force attacks.
  - **Implementation:**
    - Add an attempt counter stored in the temporary challenge record or session.
    - After 3–5 failed attempts, invalidate the challenge and require re-authentication.
    - Integrate with Devise's lockable module or provide a configurable limiter.
    - Consider Rack::Attack or application-level throttling middleware.
  - **Configuration:** Expose `config.ga_max_attempts` (default: 3) in Devise initializer.
  - **Tests:** Verify locked challenges reject further attempts; verify successful validation resets the counter.

- [ ] **1.4 Move temporary ID from URL to session-based challenge**
  - **Files:**
    - `lib/devise_gauth/controllers/helpers.rb` (lines 53–62)
    - `app/views/devise/checkga/show.html.erb`
    - `app/controllers/devise/checkga_controller.rb` (lines 24–39)
  - **Issue:** The temporary identifier is exposed in URLs, forms, browser history, reverse-proxy logs, and referrer headers.
  - **Implementation:**
    - Store the pending user and challenge state in `session[:gauth_challenge]` or similar.
    - Generate a short-lived signed/encrypted challenge token only if needed.
    - Pass the session-only identifier or omit the ID from the client entirely.
    - Validate the challenge is still present in session before accepting the token submission.
  - **Tests:** Verify challenges cannot be reused across sessions; verify URL-based lookup is no longer possible.

---

## Stage 2: High-Priority Compatibility Fixes

These changes address bugs and compatibility issues that block modern Rails and Ruby versions.

- [ ] **2.1 Fix migration template and schema type inconsistency**
  - **Files:**
    - `lib/generators/active_record/templates/migration.rb`
    - `lib/devise_gauth/schema.rb` (lines 27–38)
  - **Issues:**
    - Template renders invalid Ruby: `default: f` should be `default: false`.
    - `gauth_enabled` is declared as String in 5.2+ but Integer before; should be boolean.
    - `Datetime` is misspelled (should be `:datetime`).
  - **Implementation:**
    - Rewrite migration template to use modern Rails 6.1+ syntax.
    - Use `:boolean` type consistently with `default: false`.
    - Use `change` method instead of `self.up`/`self.down`.
    - Add an index on `gauth_tmp` for lookups.
    - Example:
      ```ruby
      class DeviseGauthAddToUsers < ActiveRecord::Migration[6.1]
        def change
          change_table :users, bulk: true do |t|
            t.string :gauth_secret
            t.boolean :gauth_enabled, null: false, default: false
            t.string :gauth_tmp
            t.datetime :gauth_tmp_datetime
          end
          add_index :users, :gauth_tmp, unique: true
        end
      end
      ```
    - Update `schema.rb` to consistently use Boolean type and `default: false`.
  - **Tests:** Generate migrations for Rails 6.1, 7.0, 7.1, 7.2, and 8.0; verify they run without errors.

- [ ] **2.2 Replace string-based Rails version comparisons**
  - **Files:**
    - `lib/devise_gauth.rb` (lines 21–25)
    - `lib/devise_gauth/schema.rb` (lines 27–32)
    - `lib/devise_gauth/rails.rb` (lines 7–13)
    - `lib/devise_gauth/controllers/helpers.rb` (lines 9–14)
    - `lib/devise_gauth/views/helpers.rb` (lines 23–28)
    - `app/controllers/devise/displayqr_controller.rb` (lines 6–9, 34)
    - `app/controllers/devise/checkga_controller.rb` (lines 4–9)
  - **Issue:** String comparisons fail for versions like `7.10` (compares as "7.1" < "7.10" is false).
  - **Implementation:**
    - Replace all `Rails.version >= 'X.Y'` with `Rails.gem_version >= Gem::Version.new('X.Y')`.
    - Consider dropping support for Rails < 6.1 to simplify the codebase.
    - If supporting older Rails is required, create a compatibility constant.
  - **Tests:** Verify version detection across Rails 6.1, 7.0, 7.1, 7.2, and 8.0.

- [ ] **2.3 Remove obsolete Rails 3/4 and Ruby 2.x compatibility code**
  - **Files:**
    - `lib/devise_gauth/controllers/helpers.rb` (lines 9–14: `before_filter` fallback)
    - `app/controllers/devise/checkga_controller.rb` (lines 4–9: `before_filter` fallback)
    - `app/controllers/devise/displayqr_controller.rb` (lines 6–9: `before_filter` fallback)
    - `lib/generators/devise_gauth/devise_gauth_generator.rb` (lines 18–24: `attr_accessible` logic)
    - `app/helpers/devise_gauth_helper.rb` (Devise 4.2 compatibility)
    - `test/test_helper.rb` (conditional Devise 4.2+ includes)
  - **Issue:** Code maintaining support for Rails 3/4 and Ruby 2.x adds clutter and testing burden.
  - **Implementation:**
    - Remove all `before_filter` fallbacks; use only `before_action`.
    - Remove all `attr_accessible` generator logic.
    - Remove Rails < 6.1 version checks and assume modern Rails APIs.
    - Update CI to test only Rails 6.1+ and Ruby 3.1+.
  - **Breaking Change:** Bump the gem to a major version (e.g., 1.0.0).
  - **Tests:** Verify ActiveRecord migrations run on modern Rails; test generators produce correct output.

- [ ] **2.4 Fix gemspec to work outside Earthly**
  - **File:** `devise_gauth.gemspec`
  - **Issue:** Requires `EARTHLY_*` environment variables unless `PUBLISHING_GEM=true`, breaking `bundle install` and IDE dependency inspection.
  - **Implementation:**
    - Set sensible defaults for local development:
      ```ruby
      earthly_ruby = ENV.fetch('EARTHLY_RUBY_VERSION', '3.4.10')
      earthly_rails = ENV.fetch('EARTHLY_RAILS_VERSION', '7.2.3')
      earthly_devise = ENV.fetch('EARTHLY_DEVISE_VERSION', '4.9.4')
      ```
    - Or simplify for publishing and let CI matrix override via Gemfile:
      ```ruby
      if ENV.fetch('PUBLISHING_GEM', false)
        spec.add_dependency 'railties', '>= 6.1', '< 9'
        spec.add_dependency 'devise', '>= 4.8', '< 6'
      else
        spec.add_dependency 'railties', rails_version
        spec.add_dependency 'devise', devise_version
      end
      ```
  - **Tests:** Run `bundle install` in a fresh checkout without environment variables.

- [ ] **2.5 Update Ruby version constraint for Ruby 4 readiness**
  - **File:** `devise_gauth.gemspec`
  - **Issue:** `<= 4.0` can exclude Ruby 4.x patch releases; no Ruby 4 CI coverage yet.
  - **Implementation:**
    - For the current major release, expand to `< 4.1` if Ruby 4.0 is tested, or keep `< 4` until Ruby 4 is added to CI.
    - For the next major release (v1.0), adopt a clear policy: e.g., `>= 3.1, < 5`.
    - Add Ruby 4.0+ jobs to GitHub Actions CI **before** changing the constraint.
  - **Tests:** CI must pass on Ruby 3.1, 3.2, 3.3, 3.4, 4.0.

---

## Stage 3: Refactoring & Code Quality

These changes improve maintainability, testability, and future-proofing without changing external behavior.

- [ ] **3.1 Replace `eval` with a route helper object**
  - **Files:**
    - `lib/devise_gauth/controllers/helpers.rb` (lines 15–19, 53–62)
  - **Issue:** Dynamic Ruby code generation and evaluation is fragile, hard to test, and security-sensitive.
  - **Implementation:**
    - Create a helper method `checkga_path_for(resource, tmpid)` that returns the correct route.
    - Use `polymorphic_path` or `send("#{resource_name}_checkga_path", id: tmpid)`.
    - Example:
      ```ruby
      def checkga_path_for(resource, tmpid)
        send(:"#{resource.class.name.singularize.underscore}_checkga_path", id: tmpid)
      end
      ```
    - Call the helper instead of `eval`.
  - **Tests:** Verify routes are generated correctly for User and custom models.

- [ ] **3.2 Refactor monkey-patched `create` to use `prepend`**
  - **Files:**
    - `lib/devise_gauth/patches.rb`
    - `lib/devise_gauth/patches/display_qr.rb` (lines 8–37)
  - **Issue:** `alias_method` is brittle under Rails reloads; `create_original` is unused; interactions with other extensions are unclear.
  - **Implementation:**
    - Rewrite using module `prepend`:
      ```ruby
      module DisplayQR
        def create
          # Custom logic here
          super
        end
      end
      ```
    - Make the patch idempotent by wrapping in a check or using `prepend` only once.
    - Move the entire logic to a clear, readable method.
  - **Tests:** Verify custom behavior is triggered; verify normal Devise registration flow still works.

- [ ] **3.3 Remove manual Warden internal API calls**
  - **Files:**
    - `app/controllers/devise/checkga_controller.rb` (lines 31)
    - `lib/devise_gauth/controllers/helpers.rb` (lines 55–57)
  - **Issues:**
    - `warden.manager._run_callbacks` is a private API (leading underscore).
    - Unscoped `warden.logout` may log out all Devise scopes.
  - **Implementation:**
    - Use `sign_in(resource, scope: scope)` with explicit scope.
    - Replace `warden.logout` with `sign_out(resource_name)`.
    - If Warden callback invocation is truly necessary, document the private API usage and plan a migration path.
  - **Tests:** Verify multiple Devise scopes remain properly isolated during TOTP flow.

- [ ] **3.4 Replace `Time.now` with `Time.current` and calculate once**
  - **Files:**
    - `lib/devise_gauth/models/google_authenticatable.rb` (lines 37–53)
  - **Issue:** Repeated `Time.now` calls create timezone inconsistencies and make tests flaky.
  - **Implementation:**
    - Calculate `now = Time.current` once per method.
    - Use `now` for challenge timestamps and drift calculations.
    - Example:
      ```ruby
      def assign_tmp
        now = Time.current
        update(gauth_tmp: ROTP::Base32.random_base32(32), gauth_tmp_datetime: now)
        gauth_tmp
      end
      ```
  - **Tests:** Use `Timecop.freeze` or `travel_to` to fix time in tests.

- [ ] **3.5 Make QR payloads URI-safe**
  - **File:** `lib/devise_gauth/views/helpers.rb` (lines 7–15)
  - **Issue:** Unescaped usernames, app names, and qualifiers can produce invalid `otpauth://` URIs.
  - **Implementation:**
    - URI-encode the label and query parameters:
      ```ruby
      def build_qrcode_data_from(username, app, gauth_secret, qualifier = nil, issuer = nil)
        label = ERB::Util.url_encode("#{username}@#{app}#{qualifier}")
        data = "otpauth://totp/#{label}?secret=#{gauth_secret}"
        data += "&issuer=#{ERB::Util.url_encode(issuer)}" if issuer
        data
      end
      ```
    - Use `Base64.strict_encode64` instead of `Base64.encode64`.
  - **Tests:** Verify QR payloads with special characters (spaces, `&`, `?`, `#`, `/`) are valid.

- [ ] **3.6 Optimize database queries**
  - **Files:**
    - `lib/devise_gauth/models/google_authenticatable.rb` (line 94)
  - **Implementation:**
    - Replace `where(gauth_tmp: gauth_tmp).first` with `find_by(gauth_tmp: gauth_tmp)`.
    - Cache `ROTP::TOTP` instance during validation to avoid recreating it multiple times.
    - Add database index on `gauth_tmp` (already done in migration fix).
  - **Tests:** Verify query count is reduced during token validation.

- [ ] **3.7 Unify generator naming**
  - **Files:**
    - `README.md`
    - `lib/generators/devise_gauth/`
    - `lib/generators/active_record/devise_google_authenticator_generator.rb`
    - `lib/generators/mongoid/devise_google_authenticator_generator.rb`
  - **Issue:** Implementation uses `devise_gauth` but README documents `devise_google_authenticator`.
  - **Implementation:**
    - Audit all generator names and file structure.
    - Update README to consistently use one naming convention.
    - Ensure all generators output the correct model/field names.
  - **Tests:** Verify all generator commands work as documented.

---

## Stage 4: Test Suite Expansion

These tests ensure security fixes and refactoring are working correctly.

- [ ] **4.1 Add token validation tests**
  - **File:** `test/models/google_authenticatable_test.rb` or new `test/totp_validation_test.rb`
  - **Tests to add:**
    - Reject non-numeric tokens (e.g., `"abc"`, `"12a34"`)
    - Reject tokens shorter or longer than 6 digits (e.g., `"1"`, `"1234567"`)
    - Reject empty or nil tokens
    - Accept only valid 6-digit numeric tokens
    - Verify malformed input no longer coerces to `0`

- [ ] **4.2 Add challenge replay/expiry tests**
  - **File:** `test/integration/gauth_test.rb` or new `test/challenge_test.rb`
  - **Tests to add:**
    - Verify temporary challenge is cleared after successful validation
    - Attempt to reuse the same challenge immediately after success (should fail)
    - Verify challenge expires after `ga_timeout` (currently tested; enhance with boundary cases)
    - Verify expired challenges reject tokens with clear error message

- [ ] **4.3 Add rate limiting tests**
  - **File:** New `test/rate_limiting_test.rb`
  - **Tests to add:**
    - Submit N failed attempts in quick succession
    - Verify challenge is locked after N attempts
    - Attempt valid token on locked challenge (should fail)
    - Verify new challenge can be requested after timeout or manual unlock

- [ ] **4.4 Add session-based challenge tests** (if Stage 1.4 is implemented)
  - **File:** `test/integration/session_challenge_test.rb`
  - **Tests to add:**
    - Verify challenge is stored in session
    - Verify challenge cannot be used across different sessions
    - Verify URL-based temporary ID lookup no longer works
    - Verify session challenge survives Rails reloads

- [ ] **4.5 Add migration tests**
  - **File:** New `test/migrations_test.rb`
  - **Tests to add:**
    - Run generated migration on Rails 6.1, 7.0, 7.1, 7.2, 8.0
    - Verify migration creates correct table schema (boolean with false default)
    - Verify rollback removes columns cleanly
    - Verify index on `gauth_tmp` is created

- [ ] **4.6 Add model namespacing & STI tests**
  - **File:** `test/models/google_authenticatable_test.rb`
  - **Tests to add:**
    - Test with namespaced model (e.g., `Admin::User`)
    - Test with STI model (e.g., `class AdminUser < User`)
    - Verify challenges are scoped correctly per model

- [ ] **4.7 Add QR code payload validation tests**
  - **File:** `test/lib/devise_gauth/views/helpers_test.rb`
  - **Tests to add:**
    - Verify QR URIs with special characters in username, app name, qualifier, issuer
    - Verify `otpauth://` format is valid
    - Verify Base64 encoding is strict (no line breaks)
    - Parse and validate generated QR payloads

- [ ] **4.8 Replace sleep-based timing tests**
  - **Files:** `test/integration/gauth_test.rb`, `test/models/google_authenticatable_test.rb`
  - **Implementation:**
    - Replace `sleep(N)` with `Timecop.freeze` or `travel_to`.
    - Use `time_travel_step` or `travel` helpers for bounded-time assertions.
  - **Tests:** Verify timeout and expiry boundaries are enforced correctly.

- [ ] **4.9 Add scope isolation tests**
  - **File:** New `test/devise_scope_test.rb`
  - **Tests to add:**
    - Verify User challenge cannot be used by AdminUser
    - Verify logging in one scope doesn't affect another scope's TOTP state
    - Verify `warden.logout` logs out only the correct scope

---

## Stage 5: Modernization & Ruby 4 Readiness

These tasks prepare the gem for Ruby 4 and Rails 8 support.

- [ ] **5.1 Add Ruby 4 and Rails 8 CI coverage**
  - **Files:**
    - `.github/workflows/ci.yml`
    - `Earthfile`
  - **Implementation:**
    - Add matrix jobs for:
      - Ruby 4.0 + Rails 7.1, Rails 7.2, Rails 8.0
      - Ruby 4.0 + Devise 4.9.4
    - Run full test suite on all new combinations.
    - Ensure no warnings or deprecations are emitted.
  - **Success Criteria:** All tests pass on Ruby 4.0 and Rails 8.0.

- [ ] **5.2 Audit and remove deprecated APIs**
  - **Files:** All files
  - **Implementation:**
    - Run `bundle audit` to check for vulnerable dependencies.
    - Check ROTP, RQRCode, and other gem changelogs for breaking changes.
    - Update dependencies to latest versions compatible with Rails 8.0.
    - Fix any deprecation warnings from Rails or Devise.
  - **Tests:** Run with `-W2` (warnings treated as errors in tests).

- [ ] **5.3 Adopt modern Rails conventions**
  - **Implementation:**
    - Use `has_secure_password` or modern authentication patterns.
    - Prefer `authenticate!` over manual session checks.
    - Use `ActionController::Parameters` exclusively.
    - Replace `respond_with` with `render` or `redirect_to` for clarity.
    - Use `form_with` instead of `form_for`.
  - **Files:** Controllers, views, tests

- [ ] **5.4 Update documentation**
  - **Files:**
    - `README.md`
    - `CHANGELOG.md`
    - Inline code comments
  - **Tasks:**
    - Document Ruby and Rails version requirements clearly.
    - Add examples for Rails 7.2 and 8.0.
    - Explain session-based challenge flow (if implemented in Stage 1).
    - Document rate limiting configuration.
    - Add troubleshooting section for common integration issues.
    - Add security best practices (e.g., HTTPS-only cookies, HSTS).

- [ ] **5.5 Plan major version release (v1.0.0)**
  - **File:** `lib/devise_gauth/version.rb`
  - **Tasks:**
    - Declare support policy: Rails 6.1+, Ruby 3.1+.
    - Drop Rails 3/4/5 support.
    - Drop Ruby 2.x support.
    - Document breaking changes and migration guide.
    - Create release notes with security fixes highlighted.
  - **Version Bump:** Update to 1.0.0.

- [ ] **5.6 Publish gem to RubyGems**
  - **Tasks:**
    - Verify all tests pass in CI.
    - Update CHANGELOG with final notes.
    - Tag commit: `git tag -a v1.0.0 -m "v1.0.0: Ruby 4 & Rails 8 Ready"`
    - Build and sign gem: `gem build devise_gauth.gemspec`
    - Push to RubyGems: `gem push devise_gauth-1.0.0.gem`
    - Create GitHub Release with notes.

---

## Implementation Timeline & Dependencies

### Phase 1: Security (Stages 1, 4.1–4.3)
**Duration:** 2–3 weeks  
**Priority:** Critical  
**Output:** Patch release (v0.6.0 or v0.7.0 if backported)

### Phase 2: Compatibility (Stages 2, 4.5–4.6, 5.1)
**Duration:** 2–3 weeks  
**Priority:** High  
**Output:** Major version candidate (v1.0.0 RC1)

### Phase 3: Refactoring (Stages 3, 4.2, 4.4, 4.7–4.9)
**Duration:** 2–3 weeks  
**Priority:** Medium  
**Output:** Polished release (v1.0.0 RC2)

### Phase 4: Documentation & Release (Stages 5.3–5.6)
**Duration:** 1 week  
**Priority:** High  
**Output:** v1.0.0 GA

---

## Notes for AI Implementation

- **Idempotency:** Each stage should be independently mergeable and testable.
- **Commits:** Create focused commits with clear messages and issue references.
- **Testing:** Run full test suite after each stage before merging.
- **Backwards Compatibility:** Stage 1–3 should maintain API compatibility; Stage 5 explicitly breaks it for v1.0.0.
- **Documentation:** Update README, CHANGELOG, and inline comments alongside code changes.
- **CI Validation:** Ensure all new CI jobs pass before declaring Ruby 4 support.
