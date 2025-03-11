# devenv

A custom Dockerized development environment to be used with IDEs such as VS Code, etc. It comes with Docker-in-Docker setup, so you need to run this container in `privileged` (that is _root_) mode.

## Persistent Docker host files

### Generate client keys

#### Windows client example

##### Generate keys

```powershell
ssh-keygen -t rsa -b 4096
```

##### Get the client pub key

```powershell
Get-Content $env:USERPROFILE\.ssh\id_rsa.pub
```

### Server keys

Server host keys are generated on container build. They are automatically created in `/etc/ssh` directory.

#### Store the keys in some directory (to be mounted to the container)

Once the server host keys are generated, you might want to persist them to prevent server's identity from being changed across rebuilds. Move the keys into the mapped directory, `ssh-host-keys` in this example.

#### Add the public client keys to the server

In order to enable the passwordless SSH login, the client keys need to be propagated to `authorized_keys` in `/home/devenv/.ssh`. The whole `/home/devenv` needs to be mapped to be persisted on the host.

Copy the contents of the public key printed by [Get the client pub key](#get-the-client-pub-key) and save it into `authorized_keys` file.

#### Permissions

The Docker image creates `devenv` user with UID and GUID of `65022` in the container. Make sure to use the correct permissions to the persistent files on the Docker host, so the container can access them.

Example listing:

```sh
root@docker-host:~# find . -maxdepth 2 -exec ls -al {} +
drwxr-xr-x 1 nobody users  4 Dec 25 07:09 .
drwxrwxrwx 1 nobody users 19 Dec 11 03:37 ..
drwxr-sr-x 1  65022 65022 11 Dec 25 07:18 home
drw------- 1 root   root   8 Dec 10 14:41 ssh-host-keys

./home:
drwxr-sr-x 1  65022 65022   11 Dec 25 07:18 .
drwxr-xr-x 1 nobody users    4 Dec 25 07:09 ..
drwx------ 1  65022 65022    3 Dec 11 11:43 .ssh

./home/.ssh:
drwx------ 1 65022 65022   3 Dec 11 11:43 .
drwxr-sr-x 1 65022 65022  11 Dec 25 07:18 ..
-rw------- 1 65022 65022 741 Dec 11 02:32 authorized_keys

./ssh-host-keys:
drw------- 1 root   root     8 Dec 10 14:41 .
drwxr-xr-x 1 nobody users    4 Dec 25 07:09 ..
-r-------- 1 root   root   513 Dec 10 13:14 ssh_host_ecdsa_key
-rw-r--r-- 1 root   root   179 Dec 10 13:14 ssh_host_ecdsa_key.pub
-r-------- 1 root   root   411 Dec 10 13:14 ssh_host_ed25519_key
-rw-r--r-- 1 root   root    99 Dec 10 13:14 ssh_host_ed25519_key.pub
-r-------- 1 root   root  2602 Dec 10 13:14 ssh_host_rsa_key
-rw-r--r-- 1 root   root   571 Dec 10 13:14 ssh_host_rsa_key.pub
```

### Docker mounts

 Prepare the folders: `~/ssh-host-keys` and `~/home/.ssh/authorized_keys` in the Docker host, and specify the mounts in the Docker container configuration as follows.

| Host Path       | Container Path                    |
|-----------------|-----------------------------------|
| ~/ssh-host-keys | /etc/ssh/ssh-host-keys            |
| ~/home          | /home/devenv                      |

This way the whole `/home/devenv`, the home dir of the container's user (`devenv`), will get mounted from the host, so everything specific to that user (settings, keys, workspaces, projects, etc.) will get persisted.
