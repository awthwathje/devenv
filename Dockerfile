FROM debian:bookworm-slim

ARG USER=devenv
ARG UID_GID=65022
ARG SSHD_MISC_CONFIG=98-misc.conf
ARG SSHD_KEYS_CONFIG=99-custom-host-keys.conf
ARG HOME_DIR=/home/devenv
ARG START_SCRIPT=start.sh

RUN apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --yes \
    ca-certificates libstdc++6 ncurses-bin coreutils make gcc g++ libgcc-s1 util-linux binutils findutils \
    gnupg openssl openssh-server \
    grep curl git vim bash zsh \
    python3

RUN rm -rf /var/lib/apt/lists/*

RUN groupadd --gid ${UID_GID} ${USER} && \
    useradd --create-home --uid ${UID_GID} --gid ${USER} --shell /bin/zsh ${USER} && \
    passwd --delete ${USER}

ADD ${SSHD_MISC_CONFIG} /etc/ssh/sshd_config.d/${SSHD_MISC_CONFIG}
ADD ${SSHD_KEYS_CONFIG} /etc/ssh/sshd_config.d/${SSHD_KEYS_CONFIG}

WORKDIR ${HOME_DIR}

EXPOSE 22

ADD ${START_SCRIPT} /usr/local/bin/${START_SCRIPT}
RUN chmod u+x /usr/local/bin/${START_SCRIPT}

ENTRYPOINT ["/usr/local/bin/start.sh"]

CMD ["/bin/zsh", "--no-log-init"]
