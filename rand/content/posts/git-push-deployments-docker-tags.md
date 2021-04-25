+++
title = "Heroku-style deployments with Docker and git tags"
date = "2021-04-25"
author = "Ricardo Ander-Egg Aguilar"
tags = ["software engineering", "git", "docker", "devops"]
thumbnail = "img/social/git_push_prod.png"
+++

In this post I want to explain a new deployment method I came up with while working on [drwn.io](https://drwn.io). 

I wanted it to meet a few requirements:

* Simple
* Based on git tags
* Zero-downtime
* Easy rollbacks


## Creating an empty remote in the server

Imagine you already have your project with some code that is being synchronized with a git service like GitHub. To have a `git push` based deployment, we need to have our own remote. We will push our code to that remote the same way we do to GitHub.

You can do that with any remote server you have by creating a folder (I'll call it `gitrem/`) and executing `git init --bare` **inside the newly created folder**. That command will initialize an empty git remote that you can use.

Now the folder will have some new things inside, it will look something like:

```
branches  config  description  HEAD  hooks  index  info  logs  objects  refs
```

(I will also run all the commands as if I had root access to the server).

In your local computer, go to your project's folder and run:

```bash
git remote add production root@[your server IP]:/root/gitrem
```

You may need to change `root` with your username and `/root/gitrem` with whatever folder you have used.

That command will add a new remote to our project. You can view all the remotes with the command `git remote -v`. It will show something like:

```
origin	git@github.com:[your github username]/[the repo name].git (fetch)
origin	git@github.com:[your github username]/[the repo name].git (push)
production	root@[your server IP]:/root/gitrem (fetch)
production	root@[your server IP]:/root/gitrem (push)
```

## Executing something when we push new code

To execute something after a git action we can use [git hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks). Git hooks live in the `.git/hooks` folder. There are client-side hooks and server-side hooks. Client-side hooks run on the computer doing the action (your local computer). Server-side hooks run on the computer "receiving" the action (our remote server). We need to set up a `post-receive` hook. That hook will run after new code is pushed to the remote.

**Some notes about the `post-receive` hook**: It can't stop the code from being pushed, and you'll stay connected to the remote server while it's executing.

## Our Docker images

Before going through our git hook, let me explain how the architecture looks. We have one load balancer/reverse proxy, I'll be using [Caddy](https://caddyserver.com/) here. Then we will be running 2 copies of our web backend. The 2 copies have different names so that we can keep one alive if our deployment is not successful. This is the `docker-compose.yaml` (with some details omitted):

```dockerfile
version: "3.8"
services:
  caddy:
    build:
      context: .
      dockerfile:
        Dockerfile.caddy
    # giving it a name to use with ufw-docker
    container_name: caddy_cont_1
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - caddy_data:/data
      - caddy_config:/config

  web:
    build:
      context: .
      dockerfile:
        Dockerfile
    ports:
      # expose port to localhost too
      - "8000:8000"


  web2:
    build:
      context: .
      dockerfile:
        Dockerfile
    ports:
      - "8000"


volumes:
  caddy_data:
  caddy_config:
```

There are 2 important things to notice here.

`web` and `web2` are **the same** container, but with different names. The only difference is that `web` exposes the port both to the internal docker-compose network **and to localhost** (that will be important later). `web2` only exposes it to the internal docker-compose network.

I'm giving a custom name to the reverse proxy image. Docker does not play well with iptables, so I use [ufw-docker](https://github.com/chaifeng/ufw-docker) to set up the firewall.


## Creating our hook

The hook is a bash script that will do the following.

1. Build the `caddy` container
2. Open the firewall ports (if needed)
2. Build the `web` container
3. If there are no errors, start the `web` container.
4. Wait until `web` is ready (with a timeout)
5. Build and start `web2`. Since it's the same as `web`, if `web` was built and run correctly, we can safely do all at once with `web2`.

We will use some git environment variables to run and move the code. We are interested in 2 of them*

`GIT_DIR`: location of the remote
`GIT_WORK_TREE`: location to put the code when it's received

We already have the folder for `GIT_DIR` (the one called `gitrem/`), but we need another folder for our code. We can create it wherever we want, let's call it `appcode/`.

Then we will have a loop checking for the inputs. The line `if [[ $ref =~ .*/main$ ]];` is checking that we are pushing to the `main` branch (change it to `master` or whatever you use if needed). Then with `git --work-tree=$GIT_WORK_TREE --git-dir=$GIT_DIR checkout -f main` we are copying the contents from that branch to our `GIT_WORK_TREE` folder (`appcode/`).

Lastly, we will use `curl` inside a loop to wait until the first replica is alive and deploy recreate the second one.

Here's the full code. I included so extra comments inside:

```bash
#!/usr/bin/env bash

set -euo pipefail

fail () { echo $1 >&2; exit 1; }
[[ $(id -u) = 0 ]] || fail "Please run 'sudo $0'"

unset GIT_INDEX_FILE
unset GIT_DIR
unset GIT_WORK_TREE

export GIT_DIR=/root/gitrem
export DOCKER_OPTS=""
export GIT_WORK_TREE=/root/appcode

while read oldrev newrev ref
do
    # change for tags
    if [[ $ref =~ .*/main$ ]];
    then
        echo "Main ref received.  Deploying main branch to production..."
        git --work-tree=$GIT_WORK_TREE --git-dir=$GIT_DIR checkout -f main
    else
        echo "Ref $ref successfully received.  Doing nothing: only the main branch may be deployed on this server."
    fi
done

# sudo ufw allow proto tcp from any to any port 80,443

# NOTE
# here you can do other operations needed to run your app like setting the appropriate
# permissions to access folders, etc.

# ufw allow http && ufw allow https

# here is the reason to use a custom container name for the reverse proxy
# these 2 commands will open ports 80 and 443 from outside to the specified docker compose service (caddy_cont_1)

ufw-docker allow caddy_cont_1 443
ufw-docker allow caddy_cont_1 80

cd $GIT_WORK_TREE

# build the containers

docker-compose -f docker-compose.yaml build

# exit code of the last executed command
# if it's not 0, stop and exit
if [[ "$?" != "0" ]]; then
  echo "error while building image."
  exit 1
fi

echo "Starting new container..."
sleep 1

# start reverse proxy and replica 1
docker-compose -f docker-compose.yaml up -d --no-deps caddy
docker-compose -f docker-compose.yaml up -d --no-deps web

# if the first replica did not start correctly, exit

if [[ "$?" != "0" ]]; then
  echo "error while deploying image."
  exit 1
  # docker-compose -f docker-compose.yaml up -d --no-deps --scale web2=2
  # docker tag "$prev_tag" imagename
  # docker-compose -f docker-compose.yaml up -d --no-deps web
fi

# (optional) some sleep time to let the first replica start

sleep 5

# wait for it to be available

attempt_counter=0

# max number of curl retries
max_attempts=10

# since the "web" serive is exposing port 8000 to the localhost, we can send requests to it from our
# script

# the following loop will query the /healthz enpoint until it receives an "ok" response. It will retry every 5 seconds and each request has a timeout of 6 seconds. It will do a maximum of 10 attempts. In summary, if the app has not started in 10*6*5 = 300 seconds = 5 minutes, exit. This number is probably to high for most use cases, so change those variables for your needs.

until $(curl --output /dev/null --max-time 6 --silent --get --fail localhost:8000/healthz); do
    if [ ${attempt_counter} -eq ${max_attempts} ];then
      echo "Max attempts reached"
      exit 1
    fi

    printf '.'
    attempt_counter=$(($attempt_counter+1))
    sleep 5
done

# if the loop finishes correctly, it means the "web" service is up and the /healthz endpoint
# is working, so we can recreate the second replica ("web2")

echo "Replica is up, creating second replica"

docker-compose -f docker-compose.yaml up -d --no-deps web2
docker-compose -f docker-compose.yaml up -d
```

**\<Note\>**

You can customize health checks in your reverse proxy to reduce the chance of having a failed request while apps are getting recreated. In my case (with a Caddyfile) I was using:

```caddyfile
drwn.io {
    reverse_proxy web:8000 web2:8000 {
        health_interval 300ms
        lb_policy least_conn
        health_path /healthz
    }
}
```

Technically, there's a 300ms window where a request could fail because the reverse proxy hasn't noticed that this upstream server is down, and it could forward a request to it. We could reduce that to a lower value if needed.

**\</Note\>**

We need to put that code inside `.git/hooks/post-receive` in our remote server. In our example it would be `/root/gitrem/.git/hooks/post-receive`. Don't forget to give it execution permissions with `chmod +x /root/gitrem/.git/hooks/post-receive`.

## Back to our local computer

We have now set up everything we need in our remote. In our local computer we can run:

```bash
git add -u .
git commit --allow-empty -m "deploy" && git push production main
```

That will push our code to our custom git remote, the `post-receive` hook will run, and we will have our app built and running!

## Rollbacks and easier deployments

Now we have deployments based on `git push`, but we can do better. We will do it using [git tags](https://git-scm.com/book/en/v2/Git-Basics-Tagging). If you don't know what git tags are, you can imagine you are playing a video game where you can save your game. You save quite often (`git push`), but some saves are more important, and you will give them a name or ID, that's a git tag. Git tags are usually used to identify release versions. We will use them to identify versions in our app, we need the following:

* Create a tag for a specific release
* Move our custom remote to that tag. The `post-receive` hook will get executed with the code we had when we created the tag.

To create a tag, we can run the following commands. They will create a new commit and an associated tag called `v2`.

```bash
# add files
git add .
git commit --allow-empty -m "tagger"
git tag -a v2 -m "version v2"
```

We can get the commit hash associated with that tag using [git rev-list](https://git-scm.com/docs/git-rev-list): `git rev-list -n 1 v2`.

For this example, we'll imagine our hash is `425368b5` (a real hash is longer than that).

Ok, we have tags and the commit hash associated to that tag. The last thing we need is some way to move our custom remote to that commit. Luckily, there's also a command for that:

```bash
git push -f production +425368b5:main
```

If you are wondering about the `+425368b5:main`, this is called [refspec](https://git-scm.com/book/en/v2/Git-Internals-The-Refspec). The tl;dr is:

* `425368b5`: commit reference
* `main`: branch name
* `+`: update the reference even if it isn’t a fast-forward

That will make our custom remote go to that specific commit, do a checkout and trigger the `post-receive` hook. This is also a good time to wrap things inside functions:

```bash
function tag {
    git add -u .
    git commit --allow-empty -m "tagger"
    git tag -a "$1" -m "version $1"
}

function totag {
    tagname="$1"
    git push -f production +"$(git rev-list -n 1 $tagname)":main
}

function deploy {
    tag "$1"
    totag "$1"
}

```

Now we can run `deploy v2` and bam! We have our app running. If you want to roll back to a previous tag, you can do it by running `totag v1` (or any other tag name).

Extra, you can view all the tags in a git repository sorted by creation date with the command:

```bash
git tag --sort=taggerdate
```

This would also be a good chance to give the [Taskfile](https://github.com/polyrand/Taskfile) a try.

## Wrapping up

We have created a custom git remote with `post-receive` hook. It will build our app as a docker container when we push new code. We can use a few git commands to move that remote to a specific commit. We have used git tags to identify important commits (releases).