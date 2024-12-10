FROM alpine

ARG USER=devenv
ARG UID_GID=65022
ARG APP_DIR=/home/devenv
ARG START_SCRIPT=start.sh
ARG SSH_KEYS_DIR=ssh-host-keys
ARG SSH_KEYS_CONFIG=99-custom-host-keys.conf

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates bash openssh git curl

RUN addgroup -g ${UID_GID} ${USER} && \
    adduser -D -G ${USER} -u ${UID_GID} ${USER}

ADD ${SSH_KEYS_CONFIG} /etc/ssh/sshd_config.d/${SSH_KEYS_CONFIG}

WORKDIR ${APP_DIR}

ADD ${START_SCRIPT} ./${START_SCRIPT}

RUN chgrp ${USER} ./${START_SCRIPT}
RUN chmod u-x,g+x,o-x ./${START_SCRIPT}

USER ${USER}

EXPOSE 22

CMD ["./start.sh"]
