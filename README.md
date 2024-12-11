# devenv
A custom Dockerized development environment to be used with IDEs such as VS Code, etc.

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

### Generate server keys
```sh
ssh-keygen -A
```

#### Store the keys in some directory (to be mounted to the container)
Those server keys need to be persisted, so it's best to store them on the host and mount them to the container at run time. You can copy the generated keys to `ssh-host-keys` dir.

#### Add the public client keys to the server
The client keys need to be propagated to `authorized_keys` on the Docker host and this file also needs to be mounted to the container at run time.

Copy the contents of the public key printed by [Get the client pub key](#get-the-client-pub-key) and save it into `authorized_keys` file.

#### Permissions
The Docker image creates `devenv` user with UID and GUID of `65022` in the container. Make sure to use the correct permissions to the persistent files on the Docker host, so the container can access them.

Example listing:
```sh
root@docker-host:~# find . -maxdepth 1 -exec ls -al {} +
-rw------- 1  65022 65022 741 Dec 11 02:32 ./authorized_keys

.:
total 24
drwxr-xr-x 1 nobody users   4 Dec 11 02:33 .
drwxrwxrwx 1 nobody users  20 Dec 11 03:25 ..
-rw------- 1  65022 65022 741 Dec 11 02:32 authorized_keys
drw------- 1 root   root    8 Dec 10 14:41 ssh-host-keys

./ssh-host-keys:
total 40
drw------- 1 root   root     8 Dec 10 14:41 .
drwxr-xr-x 1 nobody users    4 Dec 11 02:33 ..
-r-------- 1 root   root   513 Dec 10 13:14 ssh_host_ecdsa_key
-rw-r--r-- 1 root   root   179 Dec 10 13:14 ssh_host_ecdsa_key.pub
-r-------- 1 root   root   411 Dec 10 13:14 ssh_host_ed25519_key
-rw-r--r-- 1 root   root    99 Dec 10 13:14 ssh_host_ed25519_key.pub
-r-------- 1 root   root  2602 Dec 10 13:14 ssh_host_rsa_key
-rw-r--r-- 1 root   root   571 Dec 10 13:14 ssh_host_rsa_key.pub
```

### Docker mounts
In the Docker container configuration, specify the mounts as follows. Here in this example it is assumed the host files are in the home directory (`~`), change this to the actual path.

| Host Path         | Container Path                    |
|-------------------|-----------------------------------|
| ~/ssh-host-keys   | /etc/ssh/ssh-host-keys            |
| ~/authorized_keys | /home/devenv/.ssh/authorized_keys |
