VERSION 0.7

# This allows one to change the running Ruby version with:
#
# `earthly --allow-privileged +test --EARTHLY_RUBY_VERSION=3`
ARG --global EARTHLY_RUBY_VERSION=2.7

# This allows one to change the running Rails version with:
#
# `earthly --allow-privileged +test --EARTHLY_RAILS_VERSION=7`
ARG --global EARTHLY_RAILS_VERSION=5.2.8.1

# This allows one to change the running Rails version with:
#
# `earthly --allow-privileged +test --EARTHLY_DEVISE_VERSION=4.8.1`
ARG --global EARTHLY_DEVISE_VERSION=4.9.3

FROM ruby:$EARTHLY_RUBY_VERSION
WORKDIR /gem

deps:
    RUN apt update \
        && apt install --yes \
                       --no-install-recommends \
                       build-essential \
                       git

    COPY Gemfile /gem/Gemfile
    COPY *.gemspec /gem

    RUN bundle install --jobs $(nproc)

    RUN cat /gem/Gemfile.lock

    SAVE ARTIFACT /usr/local/bundle bundler
    SAVE ARTIFACT /gem/Gemfile Gemfile
    SAVE ARTIFACT /gem/Gemfile.lock Gemfile.lock

dev:
    ENV EARTHLY_DEVISE_VERSION=$EARTHLY_DEVISE_VERSION
    ENV EARTHLY_RAILS_VERSION=$EARTHLY_RAILS_VERSION
    ENV EARTHLY_RUBY_VERSION=$EARTHLY_RUBY_VERSION

    RUN apt update \
        && apt install --yes \
                       --no-install-recommends \
                       git \
        && useradd -ms /bin/bash rubydev \
        && chown -R rubydev:rubydev /gem

    COPY --chown rubydev:rubydev +deps/bundler /usr/local/bundle
    COPY --chown rubydev:rubydev +deps/Gemfile /gem/Gemfile
    COPY --chown rubydev:rubydev +deps/Gemfile.lock /gem/Gemfile.lock

    COPY --chown rubydev:rubydev *.gemspec /gem
    COPY --chown rubydev:rubydev Rakefile /gem

    COPY --chown rubydev:rubydev app/ /gem/app/
    COPY --chown rubydev:rubydev config/ /gem/config/
    COPY --chown rubydev:rubydev lib/ /gem/lib/
    COPY --chown rubydev:rubydev test/ /gem/test/

    USER rubydev

    ENTRYPOINT ["bundle", "exec"]
    CMD ["rake"]

    SAVE IMAGE pharmony/devise_google_authenticator:latest

#
# This target runs the test suite.
#
# Use the following command in order to run the tests suite:
# earthly --allow-privileged +test
test:
    FROM earthly/dind:alpine

    COPY docker-compose-earthly.yml ./

    WITH DOCKER --load pharmony/devise_google_authenticator:latest=+dev
        RUN set -e \
            && echo 0 > exit_code \
            && (docker-compose -f docker-compose-earthly.yml run \
                --rm gem \
                || echo $? > exit_code)
    END

    SAVE ARTIFACT exit_code AS LOCAL exit_code

    IF [ "$(cat exit_code)" != "0" ]
        SAVE ARTIFACT ./tmp/capybara/* AS LOCAL ./tmp/capybara/
    END

#
# This target runs rubocop static code analyzer.
#
# Use the following command in order to run the tests suite:
# earthly --allow-privileged +rubocop
rubocop:
    FROM earthly/dind:alpine

    COPY docker-compose-earthly.yml ./

    WITH DOCKER --load pharmony/devise_google_authenticator:latest=+dev
        RUN docker-compose -f docker-compose-earthly.yml run --rm gem rubocop
    END

#
# This target is used to publish this gem to rubygems.org.
#
# Prerequiries
# You should have login against Rubygems.org so that it has created
# the `~/.gem` folder and stored your API key.
#
# Then use the following command:
# earthly +gem --GEM_CREDENTIALS="$(cat ~/.gem/credentials)" --RUBYGEMS_OTP=123456
gem:
    FROM +dev

    ARG GEM_CREDENTIALS
    ARG RUBYGEMS_OTP

    COPY --chown rubydev:rubydev .git/ /gem/
    COPY --chown rubydev:rubydev CHANGELOG.md /gem/
    COPY --chown rubydev:rubydev LICENSE /gem/
    COPY --chown rubydev:rubydev README.md /gem/

    RUN gem build devise_google_authenticator.gemspec \
        && mkdir ~/.gem \
        && echo "$GEM_CREDENTIALS" > ~/.gem/credentials \
        && cat ~/.gem/credentials \
        && chmod 600 ~/.gem/credentials \
        && gem push --otp $RUBYGEMS_OTP devise_google_authenticator-*.gem

    SAVE ARTIFACT devise_google_authenticator-*.gem AS LOCAL ./devise_google_authenticator.gem
