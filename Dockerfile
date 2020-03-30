# syntax = docker/dockerfile:1.0-experimental

ARG ALPINE_VERSION=3.10.2
ARG RUBY_VERSION=2.7.0
ARG USER=marcfreiheit
ARG GROUP=developers

ARG RBENV_ROOT=/usr/local/rbenv

ARG GHC_VERSION=8.8.2

################################################################################
# Set up environment variables, OS packages, and scripts that are common to the
# build and distribution layers in this Dockerfile
FROM alpine:${ALPINE_VERSION} AS haskell-base

ARG GHC_VERSION=8.8.2

ENV GHCUP_INSTALL_BASE_PREFIX=/home/marcfreiheit

ENV GHCUP_VERSION=0.0.8
ENV GHCUP_SHA256="e09669752067dc1268bff754237e91c4dee9b35bc4e20c280faafeef9c21ea74  ghcup"

RUN mkdir -p /home/marcfreiheit

# ToDo: Refactor because of duplicated dependencies
RUN apk upgrade --no-cache \
&&  apk add --no-cache \
        curl \
        gcc \
        git \
        libc-dev \
        xz \
        gmp-dev

RUN echo "Downloading and installing ghcup" &&\
    cd /tmp &&\
    wget -P /tmp/ "https://gitlab.haskell.org/haskell/ghcup/raw/${GHCUP_VERSION}/ghcup" &&\
    if ! echo -n "${GHCUP_SHA256}" | sha256sum -c -; then \
        echo "ghcup-${GHCUP_VERSION} checksum failed" >&2 &&\
        exit 1 ;\
    fi ;\
    mv /tmp/ghcup /usr/bin/ghcup &&\
    chmod +x /usr/bin/ghcup


FROM alpine:${ALPINE_VERSION} AS ruby

# Duplicate build arg because of https://github.com/moby/moby/issues/34129
ARG RBENV_ROOT=/usr/local/rbenv
ARG RUBY_VERSION=2.7.0

ENV RBENV_ROOT $RBENV_ROOT
ENV PATH $RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH

RUN apk add --no-cache \
      linux-headers \
      imagemagick-dev \
      libffi-dev \
      bash \
      build-base \
      readline-dev \
      openssl-dev \
      zlib-dev \
      git

RUN git clone --depth 1 https://github.com/sstephenson/rbenv.git ${RBENV_ROOT} \
&&  git clone --depth 1 https://github.com/sstephenson/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build \ 
&& ${RBENV_ROOT}/plugins/ruby-build/install.sh

RUN rbenv install $RUBY_VERSION \
&&  rbenv install 2.6.5 \
&&  rbenv global $RUBY_VERSION

COPY Gemfile .

RUN gem install bundler \
&&  bundle install

FROM alpine:${ALPINE_VERSION} AS fonts

RUN apk add --no-cache git

# install powerline fonts
RUN git clone https://github.com/powerline/fonts.git --depth=1 && \
    cd fonts && \
    ./install.sh && \
    cd .. && \
    rm -rf fonts


FROM alpine:${ALPINE_VERSION} AS kubernetes

# Note: Latest version of kubectl may be found at:
# https://aur.archlinux.org/packages/kubectl-bin/
ARG KUBE_LATEST_VERSION="v1.15.2"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ARG HELM_VERSION="v2.14.3"

RUN apk add --no-cache --virtual .build-deps ca-certificates openssh \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && apk del --no-cache .build-deps


FROM alpine:${ALPINE_VERSION} AS vim

WORKDIR /root

RUN apk add --no-cache git python3 python3-dev build-base cmake npm curl

# install vim package manager pathogen
RUN mkdir -p .vim/autoload .vim/bundle && \
    curl -LSso .vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# install vim plugins (using pathogen)
RUN git clone https://github.com/vim-airline/vim-airline.git .vim/bundle/vim-airline && \
    git clone https://github.com/christoomey/vim-tmux-navigator.git .vim/bundle/vim-tmux-navigator && \
    git clone https://github.com/luochen1990/rainbow.git .vim/bundle/rainbow && \
    git clone https://github.com/tpope/vim-fugitive.git .vim/bundle/vim-fugitive && \
    git clone https://github.com/mileszs/ack.vim.git ~/.vim/bundle/ack.vim


FROM alpine:${ALPINE_VERSION} AS tmux

ENV TMUX_PLUGIN_MANAGER_PATH=/root/.tmux/plugins

# install zsh plugins
RUN apk add --no-cache git bash tmux
COPY tmux/.tmux.conf /root/.tmux.conf
RUN git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm && /root/.tmux/plugins/tpm/bin/install_plugins


FROM alpine:${ALPINE_VERSION} AS gcloud

ENV PATH /usr/local/gcloud/google-cloud-sdk/bin:$PATH

RUN apk add --no-cache curl python3
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz && \
    mkdir -p /usr/local/gcloud && \
    tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz && \
    /usr/local/gcloud/google-cloud-sdk/install.sh
RUN gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

FROM haskell-base AS build-ghc

# Carry build args through to this stage
ARG GHC_VERSION=8.8.2

RUN echo "Install OS packages necessary to build GHC" &&\
    apk add --no-cache \
        autoconf \
        automake \
        binutils-gold \
        build-base \
        coreutils \
        cpio \
        ghc \
        linux-headers \
        libffi-dev \
        llvm5 \
        musl-dev \
        ncurses-dev \
        perl \
        python3 \
        py3-sphinx \
        zlib-dev

COPY haskell/build-gmp.mk /tmp/build.mk

RUN echo "Compiling and installing GHC" &&\
    LD=ld.gold \
    SPHINXBUILD=/usr/bin/sphinx-build-3 \
      ghcup -v compile -j $(nproc) -c /tmp/build.mk ${GHC_VERSION} ghc-8.4.3 &&\
    rm /tmp/build.mk &&\
    echo "Uninstalling GHC bootstrapping compiler" &&\
    apk del ghc &&\
    ghcup set ${GHC_VERSION}

################################################################################
# Intermediate layer that assembles 'stack' tooling
FROM haskell-base AS build-tooling

ENV STACK_VERSION=2.1.3
ENV STACK_SHA256="4e937a6ad7b5e352c5bd03aef29a753e9c4ca7e8ccc22deb5cd54019a8cf130c  stack-${STACK_VERSION}-linux-x86_64-static.tar.gz"

# Download, verify, and install stack
RUN echo "Downloading and installing stack" &&\
    cd /tmp &&\
    wget -P /tmp/ "https://github.com/commercialhaskell/stack/releases/download/v${STACK_VERSION}/stack-${STACK_VERSION}-linux-x86_64-static.tar.gz" &&\
    if ! echo -n "${STACK_SHA256}" | sha256sum -c -; then \
        echo "stack-${STACK_VERSION} checksum failed" >&2 &&\
        exit 1 ;\
    fi ;\
    tar -xvzf /tmp/stack-${STACK_VERSION}-linux-x86_64-static.tar.gz &&\
    cp -L /tmp/stack-${STACK_VERSION}-linux-x86_64-static/stack /usr/bin/stack &&\
    rm /tmp/stack-${STACK_VERSION}-linux-x86_64-static.tar.gz &&\
    rm -rf /tmp/stack-${STACK_VERSION}-linux-x86_64-static


FROM haskell-base

LABEL MAINTAINER="Marc André Freiheit <marcandre@freiheit.software>"
LABEL ALPINE_VERSION=${ALPINE_VERSION}

RUN addgroup -S developers && adduser -SDs /bin/zsh -G developers marcfreiheit
WORKDIR /home/marcfreiheit
ENV HOME /home/marcfreiheit

ARG LOCALE="de_DE"
ARG TZ="Europe/Berlin"

ARG GHC_VERSION=8.8.2

# Install and configure locals
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    apk del --purge tzdata && \
    echo "${TZ}" > /etc/timezone
ENV LANG=${LOCALE}.UTF-8 \
    LANGUAGE=${LOCALE}.UTF-8 \
    LC_ALL=${LOCALE}.UTF-8 \
    TZ=${TZ}

# Set Shell settings
ENV TERM=xterm-256color \
    SHELL=/bin/zsh \
    LIBRARY_PATH=/lib:/usr/lib

# Environment configuration for Google Cloud
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Environment configuration for Java
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV PATH="$JAVA_HOME/bin:${PATH}"

# Environment configuration for zsh
ENV TMUX_PLUGIN_MANAGER_PATH=/home/marcfreiheit/.tmux/plugins

# Environment configuration for ruby
ARG RBENV_ROOT=/usr/local/rbenv
ENV RBENV_ROOT $RBENV_ROOT
ENV PATH $RBENV_ROOT/shims:/$RBENV_ROOT/bin:$PATH

# Environment configuration for Docker
ENV COMPOSE_DOCKER_CLI_BUILD=${COMPOSE_DOCKER_CLI_BUILD}
ENV DOCKER_BUILDKIT=${DOCKER_BUILDKIT}

# Carry build args through to this stage
ARG GHC_VERSION=8.8.2

# Environment configuration for python (and pip)
ENV PATH /home/marcfreiheit/.local/bin:$PATH

ENV NODE_SASS_PLATFORM=alpine

# 1. Development tools
# 1. - Bash is required by tmux to run its plugins
# 2. Programming languages and libraries
# 3. Ruby
# 4. Haskell
# 5. Building tools
# 6. Docker
# 7. Package managers
# 8. Miscellaneous
RUN apk add --no-cache \
  git git-perl zsh tmux vim bash ack \
  python3 nodejs clang-libs openjdk8 \
  libressl readline-dev \
  xz \
  build-base python-dev py-pip jpeg-dev zlib-dev icu-dev shadow grep ruby-dev ruby-rdoc ruby-etc \
  cmake python-dev make g++ libffi-dev openssl-dev gcc libc-dev gmp-dev \
  docker \
  npm \
  su-exec which openssh-client curl py-pip less ca-certificates findutils

RUN set -xe \
&&  npm install -g node-gyp ionic cordova \
&&  rm -rf /var/cache/apk/* /tmp/*

RUN pip install docker-compose


RUN mkdir /github && chown marcfreiheit:developers /github

RUN git clone https://github.com/olivierverdier/zsh-git-prompt.git /home/marcfreiheit/zsh/git-prompt
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/marcfreiheit/zsh/zsh-syntax-highlighting

ARG COMPOSE_DOCKER_CLI_BUILD=1
ARG DOCKER_BUILDKIT=1
ARG BUILDKIT_VERSION=v0.6.4

COPY --chown=marcfreiheit:developers Gemfile .

# programming languages and frameworks
COPY --from=ruby --chown=marcfreiheit:developers $RBENV_ROOT $RBENV_ROOT
COPY --chown=marcfreiheit:developers --from=build-ghc /home/marcfreiheit/.ghcup .ghcup
COPY --chown=marcfreiheit:developers --from=build-tooling /usr/bin/stack /usr/bin/stack

# tooling
COPY --from=kubernetes /usr/local/bin/helm /usr/local/bin/helm
COPY --from=kubernetes /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=gcloud --chown=marcfreiheit:developers /usr/local/gcloud /usr/local/gcloud
COPY --from=moby/buildkit:v0.6.4 --chown=marcfreiheit:developers /usr/bin/buildctl /usr/local/bin/builtctl

# vim
COPY --chown=marcfreiheit:developers --from=vim /root/.vim /home/marcfreiheit/.vim
COPY --chown=marcfreiheit:developers vim/.vimrc .vimrc
COPY --chown=marcfreiheit:developers vim/colors .vim/colors

# tmux
COPY --chown=marcfreiheit:developers --from=tmux /root/.tmux /home/marcfreiheit/.tmux
COPY --chown=marcfreiheit:developers --from=tmux /root/.tmux.conf /home/marcfreiheit/.tmux.conf
COPY --chown=marcfreiheit:developers tmux/.remote.tmux.conf .remote.tmux.conf

# Fonts
COPY --from=fonts /root/.local/share/fonts /home/marcfreiheit/.local/share/fonts

# Entrypoint
COPY --chown=marcfreiheit:developers entrypoint.sh .

# zsh
COPY --chown=marcfreiheit:developers zsh/ zsh
RUN ln -sf zsh/.zshrc .zshrc

RUN touch /home/marcfreiheit/zsh/git-prompt/src/.bin/gitstatus && \ 
    chmod 777 /home/marcfreiheit/zsh/git-prompt/src/.bin/gitstatus

ENV GHCUP_INSTALL_BASE_PREFIX=/home/marcfreiheit
ENV PATH=/home/marcfreiheit/.ghcup/bin:$PATH

RUN ghcup set ${GHC_VERSION}

RUN chown -R marcfreiheit:developers /home/marcfreiheit/.local

RUN apk add --no-cache postgresql-dev libc6-compat

RUN ln -s /lib64/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2

ENTRYPOINT ["/home/marcfreiheit/entrypoint.sh"]
