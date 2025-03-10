#!/bin/sh
set -e

# Start the Docker daemon in the background
dockerd &

# Start the SSH daemon in the background
mkdir -p /run/sshd && chmod 0755 /run/sshd && /usr/sbin/sshd -D -e &

# Wait until the Docker daemon is fully up and running
until docker info > /dev/null 2>&1; do
  echo "Waiting for Docker daemon to start..."
  sleep 1
done

echo "Docker daemon and SSHd are up and running."

# Execute the CMD provided in the Dockerfile (e.g. /bin/zsh)
exec "$@"
