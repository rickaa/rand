+++
title = "Connect to remote docker host via SSH."
date = "2020-07-29"
author = "Ricardo Ander-Egg Aguilar"
categories = ["docker"]
tags = ["docker", "remote", "ssh"]
thumbnail = "img/social/connections1.jpg"
+++

I could not get reliable connections with docker-machine or docker context. This is how I got 100% reliable connections through ssh forwarding.

It's also more secure. You don't need to expose any additional ports.

```sh
# create bash function
function dockcon() {

	# if used with the argument `unset`, close the connection
	# see the part after this conditional to understand it better
    if [[ "$1" == "unset" ]]; then
    	# get the PID of the ssh process and kill it
        kill "$(cat docker_connection.pid)"
        
        # unset the environment variable
        unset DOCKER_HOST
        
        # remove the file with the PID
        rm docker_connection.pid
        
        # end
        return
    fi
    
    
    # generate a random integer between 27000 and 37000 to choose as a port
    PORT=$(( ( RANDOM % 10000 )  + 27000 ))
    
    # connect via ssh
    # forward the remote docker socket to a local port on your machine
    # the argument "$1" is the remote host
    # echo the PID of the ssh connection to a text file
    ssh -NL localhost:$PORT:/var/run/docker.sock "$1" & echo $! > docker_connection.pid
    
    # set the environment variable to tell docker which host to use
    export DOCKER_HOST="tcp://localhost:$PORT"
}

```

Usage:

1. (Optional) Set up your ~/.ssh/config with the correct hosts:

```
Host digitaloceanserv1
    Hostname 127.127.127.127  # whatever the ip address is
    Port 22
    User root
    IdentitiesOnly yes
    IdentityFile ~/.ssh/mykey
```

2. Run the function

```sh
dockcon digitaloceanserv1

# now you can run any docker command and it will execute as if you
# are in the remote machine

docker ps
docker build --tag=myapp .
docker run --rm --detach=true --name=mycontainer myapp

docker exec -it mycontainer bash

# disconnect
# IMPORTANT! Run it in the same folder as you were before!
# (otherwise it will not find the docker_connection.pid file)
dockcon unset

# output:
# [1]+  Done                    ssh -NL localhost:$PORT:/var/run/docker.sock "$1"
```