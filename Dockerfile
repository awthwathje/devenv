FROM debian:bookworm-slim

ARG USER=devenv
ARG UID_GID=65022
ARG SSHD_MISC_CONFIG=98-misc.conf
ARG SSHD_KEYS_CONFIG=99-custom-host-keys.conf
ARG HOME_DIR=/home/devenv
ARG START_SCRIPT=start.sh
ARG SERVICES_CONFIG=services.conf

RUN apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --yes \
    openssh-server \
    ca-certificates libstdc++6 ncurses-bin coreutils make gcc g++ libgcc-s1 util-linux binutils findutils \
    gnupg openssl iproute2 apt-transport-https lsb-release \
    grep curl git vim bash zsh \
    supervisor \
    python3

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

RUN apt-get update && \
    apt-get install --yes \
    docker-ce docker-ce-cli containerd.io docker-compose 

RUN rm -rf /var/lib/apt/lists/*

RUN groupadd --gid ${UID_GID} ${USER} && \
    useradd --create-home --uid ${UID_GID} --gid ${USER} --shell /bin/zsh ${USER} && \
    passwd --delete ${USER}

RUN usermod -aG docker ${USER}

ADD ${SSHD_MISC_CONFIG} /etc/ssh/sshd_config.d/${SSHD_MISC_CONFIG}
ADD ${SSHD_KEYS_CONFIG} /etc/ssh/sshd_config.d/${SSHD_KEYS_CONFIG}

WORKDIR ${HOME_DIR}

EXPOSE 22

ADD ${START_SCRIPT} /usr/local/bin/${START_SCRIPT}

RUN chmod u+x /usr/local/bin/${START_SCRIPT}

RUN mkdir -p /run/sshd && chmod 0755 /run/sshd

ADD ${SERVICES_CONFIG} /etc/supervisor/conf.d/${SERVICES_CONFIG}

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/services.conf"]
