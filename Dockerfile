FROM alpine

ARG USER=devenv
ARG UID_GID=65022
ARG HOME_DIR=/home/devenv
ARG SSHD_MISC_CONFIG=98-misc.conf
ARG SSHD_KEYS_CONFIG=99-custom-host-keys.conf
ARG START_SCRIPT=start.sh

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates bash openssh git curl libstdc++ libgcc gnupg

RUN addgroup -g ${UID_GID} ${USER} && \
    adduser -D -G ${USER} -u ${UID_GID} ${USER} && \
    passwd -u ${USER}

ADD ${SSHD_MISC_CONFIG} /etc/ssh/sshd_config.d/${SSHD_MISC_CONFIG}
ADD ${SSHD_KEYS_CONFIG} /etc/ssh/sshd_config.d/${SSHD_KEYS_CONFIG}

WORKDIR ${HOME_DIR}

RUN mkdir ${HOME_DIR}/.ssh && \
    chown -R ${USER}:${USER} ${HOME_DIR}/.ssh && \
    chmod 700 ${HOME_DIR}/.ssh

RUN mkdir ${HOME_DIR}/.vscode-server && \
    chown -R ${USER}:${USER} ${HOME_DIR}/.vscode-server && \
    chmod 700 ${HOME_DIR}/.vscode-server

USER ${USER}

EXPOSE 22

USER root

ADD ${START_SCRIPT} /opt/${START_SCRIPT}

RUN chmod u+x /opt/${START_SCRIPT}

CMD ["/opt/start.sh"]
