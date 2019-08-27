FROM alpine:3.9

LABEL MAINTAINER="Marc André Freiheit <marcandre@freiheit.software>"

# Note: Latest version of kubectl may be found at:
# https://aur.archlinux.org/packages/kubectl-bin/
ARG KUBE_LATEST_VERSION="v1.15.2"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ARG HELM_VERSION="v2.14.3"

# Carry build args through to this stage
ARG GHC_BUILD_TYPE=gmp
ARG GHC_VERSION=8.6.5

ENV TERM=xterm-256color
ENV TMUX_PLUGIN_MANAGER_PATH /home/me/.tmux/plugins
ENV SHELL /bin/zsh

# Create a user called 'me'
RUN adduser -Ds /bin/zsh me
# Do everything from now in that users home directory
WORKDIR /home/me
ENV HOME /home/me

RUN apk add --no-cache bash git zsh tmux vim curl python3 nodejs clang-libs docker openjdk8-jre-base cmake python3-dev make g++ npm su-exec which

# Add ghcup's bin directory to the PATH so that the versions of GHC it builds
# are available in the build layers
ENV GHCUP_INSTALL_BASE_PREFIX=/
ENV PATH=/.ghcup/bin:$PATH

COPY --from=marcfreiheit/ghcup:latest /.ghcup /.ghcup
COPY --from=marcfreiheit/haskell-stack:latest /usr/bin/stack /usr/bin/stack

# Must be one of 'gmp' or 'simple'; used to build GHC with support for either
# 'integer-gmp' (with 'libgmp') or 'integer-simple'
#
# Default to building with 'integer-gmp' and 'libgmp' support
ARG GHC_BUILD_TYPE

# Must be a valid GHC version number, only tested with 8.4.4, 8.6.4, and 8.6.5
#
# Default to GHC version 8.6.5 (latest at the time of writing)
ARG GHC_VERSION=8.6.5

# Add ghcup's bin directory to the PATH so that the versions of GHC it builds
# are available in the build layers
ENV GHCUP_INSTALL_BASE_PREFIX=/
ENV PATH=/.ghcup/bin:$PATH

# Use the latest version of ghcup (at the time of writing)
ENV GHCUP_VERSION=0.0.7
ENV GHCUP_SHA256="b4b200d896eb45b56c89d0cfadfcf544a24759a6ffac029982821cc96b2faedb  ghcup"

# Install the basic required dependencies to run 'ghcup' and 'stack'
RUN apk upgrade --no-cache &&\
    apk add --no-cache \
        curl \
        gcc \
        git \
        libc-dev \
        xz &&\
    if [ "${GHC_BUILD_TYPE}" = "gmp" ]; then \
        echo "Installing 'libgmp'" &&\
        apk add --no-cache gmp-dev; \
    fi

# Download, verify, and install ghcup
RUN echo "Downloading and installing ghcup" &&\
    cd /tmp &&\
    wget -P /tmp/ "https://gitlab.haskell.org/haskell/ghcup/raw/${GHCUP_VERSION}/ghcup" &&\
    if ! echo -n "${GHCUP_SHA256}" | sha256sum -c -; then \
        echo "ghcup-${GHCUP_VERSION} checksum failed" >&2 &&\
        exit 1 ;\
    fi ;\
    mv /tmp/ghcup /usr/bin/ghcup &&\
    chmod +x /usr/bin/ghcup

RUN mkdir -p /home/me/.stack && echo " allow-different-user: true" >> /home/me/.stack/config.yaml
RUN ghcup set ${GHC_VERSION} && \
    stack config set system-ghc --global true

RUN apk add --no-cache --virtual .build-deps ca-certificates openssh \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && apk del --no-cache .build-deps

# install gcloud tools
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz && \
    mkdir -p /usr/local/gcloud && \
    tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz && \
    /usr/local/gcloud/google-cloud-sdk/install.sh && \
    chown -R me: /usr/local/gcloud
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# install powerline fonts
RUN git clone https://github.com/powerline/fonts.git --depth=1 && \
    cd fonts && \
    ./install.sh && \
    cd .. && \
    rm -rf fonts

# install zsh plugins
RUN apk add --no-cache gmp-dev
USER me
RUN git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm && .tmux/plugins/tpm/bin/install_plugins
USER root
RUN git clone https://github.com/olivierverdier/zsh-git-prompt.git zsh/git-prompt && \
    stack init && \
    stack setup && \
    stack build && stack install && \
    touch /home/me/zsh/git-prompt/src/.bin/gitstatus && \
    chmod 777 /home/me/zsh/git-prompt/src/.bin/gitstatus 

# install vim package manager pathogen
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle && \
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# install and compise YouCompleteMe
RUN git clone https://github.com/ycm-core/YouCompleteMe.git .vim/bundle/ycm && \
    cd .vim/bundle/ycm && \
    git submodule update --init --recursive && \
    python3 install.py --clang-completer --ts-completer --java-completer
    
# install vim plugins (using pathogen)
RUN git clone https://github.com/vim-airline/vim-airline.git .vim/bundle/vim-airline && \
    git clone https://github.com/kien/ctrlp.vim.git .vim/bundle/ctrlp.vim && \
    git clone https://github.com/christoomey/vim-tmux-navigator.git .vim/bundle/vim-tmux-navigator && \
    git clone https://github.com/luochen1990/rainbow.git .vim/bundle/rainbow && \
    git clone https://github.com/tpope/vim-fugitive.git .vim/bundle/vim-fugitive

# copy and link configuration files
COPY --chown=me:me zsh/ zsh
COPY --chown=me:me zsh/.zshrc .zshrc

COPY --chown=me:me vim/.vimrc .vimrc
COPY --chown=me:me vim/colors .vim/colors

COPY --chown=me:me tmux/.tmux.conf .tmux.conf
COPY --chown=me:me tmux/.remote.tmux.conf .remote.tmux.conf

RUN ln -sf zsh/.zshrc .zshrc

RUN apk add --no-cache openssh-client
RUN chown me: /home/me/.tmux
USER me
RUN  /home/me/.tmux/plugins/tpm/bin/install_plugins
USER root
COPY entrypoint.sh .
ENTRYPOINT ["/home/me/entrypoint.sh"]
