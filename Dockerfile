FROM ruby:2.7.1 as base

WORKDIR /rubygems/bundler
CMD ["bin/rake", "spec"]

RUN apt-get update \
 # from https://github.com/rubygems/rubygems/blob/035984c789d1a793e5dffcae0a285a63558a8e7e/bundler/doc/development/SETUP.md
 && apt-get install -y graphviz groff-base bsdmainutils \
 # for compiling git
 && apt-get install -y make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip

COPY ./rubygems /rubygems

RUN bin/rake spec:deps

FROM base as latest_git

RUN git --version \
 && cd /tmp \
 && wget https://github.com/git/git/archive/v2.28.0.zip -O git.zip \
 && unzip git.zip \
 && cd git-* \
 && make prefix=/usr/local all \
 && make prefix=/usr/local install

FROM base as non_root

RUN adduser -D austinpray
RUN chown -R austinpray:austinpray /rubygems
USER austinpray