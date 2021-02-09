+++
title = "Run your containers as non-root"
date = "2020-07-22"
author = "Ricardo"
categories = ["docker", "security"]
tags = ["docker", "security", "root"]
thumbnail = "img/social/docker_sec.png"
+++

Docker runs as root. The programs executing inside containers too. Make it a bit better.

```docker
# do everything you need as root (maybe installing some dependencies)

# create a non-root user
RUN addgroup --gid 1001 appgroup
RUN useradd --create-home --gid 1001 --uid 1001 appuser

# set new workdir
WORKDIR /home/appuser

# activate non-root user
USER appuser

# copy new files with correct permissions
COPY --chown=appuser:appgroup app.py .
```

If you need to mount or use files from your file system, give permissions to the UID/GID defined above:

```sh
# set ownership, recursive, userid:groupid
chown -R 1001:1001 /data/myvolume

# full access to members of the group (read+write+execute)
chmod 775 /data/myvolume

# inherit group ownership
chmod g+s /data/myvolume

# Add your host user to the group allowing you to conveniently work with the directory from your host machine
adduser <your-username> 1001
```

Sources:
* https://pythonspeed.com/articles/root-capabilities-docker-security/
* https://pythonspeed.com/articles/dockerizing-python-is-hard/
* https://medium.com/@nielssj/docker-volumes-and-file-system-permissions-772c1aee23ca