FROM ruby:2.7.0-alpine3.11

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN apk add --update --no-cache \
  build-base \
  nodejs \
  tzdata \
  yarn \
&& cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
&& echo "Asia/Tokyo" > /etc/timezone

RUN mkdir /app
WORKDIR /app

RUN gem install -N bundler
RUN bundle config --global silence_root_warning 1
RUN bundle config set path 'vendor/bundle'

# https://github.com/sass/sassc-ruby/issues/146
ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native

COPY . /app

EXPOSE 80
