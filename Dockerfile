FROM ruby:2.3
MAINTAINER Sumit Khanna<sumit@penguindreams.org>

RUN apt-get update && apt-get install -y nodejs

ENV BUILD_DIR /dyject
RUN mkdir -p $BUILD_DIR/build
WORKDIR $BUILD_DIR
VOLUME [$BUILD_DIR/build]

COPY config.rb $BUILD_DIR/
COPY Gemfile $BUILD_DIR/
COPY Gemfile.lock $BUILD_DIR/
COPY source $BUILD_DIR/source
RUN bundle install

CMD middleman build -c
