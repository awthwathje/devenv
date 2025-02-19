FROM alpine

ARG USER=devenv
ARG UID_GID=65022
ARG SSHD_MISC_CONFIG=98-misc.conf
ARG SSHD_KEYS_CONFIG=99-custom-host-keys.conf
ARG HOME_DIR=/home/devenv
ARG START_SCRIPT=start.sh

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        ca-certificates libstdc++ ncurses coreutils make gcc g++ libgcc linux-headers util-linux binutils findutils \
        openssl openssh gnupg \
        grep curl git \
        vim bash zsh \
        python3

RUN addgroup -g ${UID_GID} ${USER} && \
    adduser -D -G ${USER} -u ${UID_GID} ${USER} && \
    passwd -u ${USER}

ADD ${SSHD_MISC_CONFIG} /etc/ssh/sshd_config.d/${SSHD_MISC_CONFIG}
ADD ${SSHD_KEYS_CONFIG} /etc/ssh/sshd_config.d/${SSHD_KEYS_CONFIG}

WORKDIR ${HOME_DIR}

RUN sed -i 's|^\(devenv:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:\)/bin/sh|\1/bin/zsh|' /etc/passwd

EXPOSE 22

ADD ${START_SCRIPT} /usr/local/bin/${START_SCRIPT}

RUN chmod u+x /usr/local/bin/${START_SCRIPT}

CMD ["/usr/local/bin/start.sh"]
