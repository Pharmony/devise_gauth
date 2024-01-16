VERSION 0.7

#
# Please check on Ruby/Rails version compatibilities from https://www.fastruby.io/blog/ruby/rails/versions/compatibility-table.html
#

# This allows one to change the running Ruby version with:
#
# `earthly --allow-privileged +test --EARTHLY_RUBY_VERSION=3`
ARG --global EARTHLY_RUBY_VERSION=2.5

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

    COPY lib/devise_google_authenticatable/version.rb lib/devise_google_authenticatable/version.rb
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

    SAVE IMAGE pharmony/devise_gauth:latest

#
# This target runs the test suite.
#
# Use the following command in order to run the tests suite:
# earthly --allow-privileged +test
test:
    FROM earthly/dind:alpine

    COPY docker-compose-earthly.yml ./

    WITH DOCKER --load pharmony/devise_gauth:latest=+dev
        RUN set -e \
            && echo 0 > exit_code \
            && (docker-compose -f docker-compose-earthly.yml run \
                --rm gem \
                || echo $? > exit_code)
    END

    RUN echo "Exit code is $(cat exit_code)"

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

    WITH DOCKER --load pharmony/devise_gauth:latest=+dev
        RUN docker-compose -f docker-compose-earthly.yml run --rm gem rubocop
    END

#
# This target is used to publish this gem to rubygems.org.
#
# Prerequiries
# 1. You need an API key with the "Push rubygem" scope
# 2. You should create a `.secret` file containing:
# ```
# GEM_HOST_API_KEY=<your API key here>
# ```
#
# Then use the following command:
# earthly +gem --RUBYGEMS_OTP=123456
#
# In the case you don't want to use a `.secret` file, then use this command:
# earthly --secret GEM_HOST_API_KEY=<API KEY> +gem --RUBYGEMS_OTP=123456
gem:
    FROM +dev

    ENV PUBLISHING_GEM=true
    ARG RUBYGEMS_OTP

    COPY --chown rubydev:rubydev .git/ /gem/.git/
    COPY --chown rubydev:rubydev CHANGELOG.md /gem/
    COPY --chown rubydev:rubydev LICENSE.txt /gem/
    COPY --chown rubydev:rubydev README.md /gem/

    RUN gem build devise_gauth.gemspec
    RUN --secret GEM_HOST_API_KEY gem push --otp $RUBYGEMS_OTP devise_gauth-*.gem

    SAVE ARTIFACT devise_gauth-*.gem AS LOCAL ./devise_gauth.gem
