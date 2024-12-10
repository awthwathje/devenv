FROM alpine

ARG USER=devenv
ARG UID_GID=65022
ARG HOME_DIR=/home/devenv
ARG START_SCRIPT=start.sh
ARG SSH_KEYS_CONFIG=99-custom-host-keys.conf

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates bash openssh git curl

RUN addgroup -g ${UID_GID} ${USER} && \
    adduser -D -G ${USER} -u ${UID_GID} ${USER}

ADD ${SSH_KEYS_CONFIG} /etc/ssh/sshd_config.d/${SSH_KEYS_CONFIG}

WORKDIR ${HOME_DIR}

RUN chown -R ${USER}:${USER} ${HOME_DIR}/.ssh && \
    chmod 600 ${HOME_DIR}/.ssh/authorized_keys

USER ${USER}

EXPOSE 22

ADD ${START_SCRIPT} /opt/${START_SCRIPT}

USER root

CMD ["/opt/start.sh"]
