+++
title = "Managing Python environments with mamba and pip-tools"
date = "2021-01-25"
author = "Ricardo"
tags = ["conda", "environment", "python", "mamba", "pip-tools", "docker"]
thumbnail = "img/social/conda_management.jpg"
+++


Some time ago I published [a post](https://ricardoanderegg.com/posts/conda_management/) about managing Conda environments. My workflow has changed quite a bit since then, and I've moved to [venv](https://docs.python.org/3/tutorial/venv.html) + [pip-tools](https://github.com/jazzband/pip-tools), but I'll leave that for another post. Today I want to talk about new experiments I'm making with [mamba](https://github.com/mamba-org/mamba) + [pip-tools](https://github.com/jazzband/pip-tools). If you don't know about mamba, it's kind of a [miniconda](https://docs.conda.io/en/latest/miniconda.html) replacement. It just works a lot better, and it's VERY fast.

Triggered by [this tweet](https://twitter.com/full_stack_dl/status/1346606996011642883), I feel like writing about this new experimental workflow. We will see how it works, some problems that may come up and workarounds to fix them.

## Creating a "dev" conda environment

Thanks to the [new features in JupyterLab 3.0](https://blog.jupyter.org/jupyterlab-3-0-is-out-4f58385e25bb?gi=e419334ae687), installing Jupyter extensions is a lot easier. I create my "dev" environment with this script:


```bash
#!/usr/bin/env bash

set -e
set -x

if [ $# -eq 0 ]; then
    echo "Usage: conda_base.sh [VERSION]
Example: conda_base.sh 3.7"
    exit 1
fi

NAME="dev"
VERSION=$1

echo "Creating environment with name: $NAME"
echo "Using Python version: $VERSION"


conda create --name "$NAME" python="$VERSION"
mamba install -y --name "$NAME" -c conda-forge ipython jupyterlab=3 nb_conda_kernels black isort
mamba install -y --name "$NAME" -c conda-forge jupyterlab_code_formatter ipywidgets

```

One of the key libraries is [nb\_conda\_kernels](https://github.com/Anaconda-Platform/nb_conda_kernels), it makes this conda environment the ability to "discover" ipython kernels in other conda environments.

## TL;DR / managing environments

We create the environment (called "tester") for our new project and install what we need:

```bash
mamba create --name "tester" python=3.7

mamba install -y --name "tester" -c conda-forge numpy pandas ipykernel pip-tools fastapi
```

**NOTE**: pip-tools has to be installed in the same environment from which you are going to use it

Now we write our file for pip-tools `requirements.in`.

```
# requirements.in
numpy
pandas
fastapi
```

And compile it with:

```
# activate the conda environment (conda activate tester)
pip-compile -v --output-file requirements.txt requirements.in
```

Finally, write a Dockerfile, build and run it:


```docker
FROM python:3.7-slim-buster

COPY requirements.txt .

RUN pip install -r requirements.txt
```

```sh
# `csq` is just a random name I gave the image

docker image build -t csq . && docker run --rm csq
```

## Problems with pip extras

Some Python packages can include "extras". For example, you can run `pip install fastapi[all]` to install [FastAPI](https://fastapi.tiangolo.com/) + many other dependencies. However, maybe you don't want to install everything.

The `extras` syntax `pip install somepackage[extras]` is [not](https://github.com/conda/conda/issues/7502) [available](https://github.com/conda/conda/issues/2984) in conda.

Without this kind of control, some dependencies may sneak in your projects. One option is installing them with `pip`, but then you lose some advantages of using conda.

## Problems with PyTorch

We now need to add PyTorch to our project, and we run:

```sh
mamba install -y --name "tester" pytorch torchvision -c pytorch
```

Update your `requirements.in` file:

```
# requirements.in
# file in macOS
numpy
pandas
fastapi
torch
torchvision
```

Finally, we run the `pip-compile` command again to generate the `requirements.txt` file with pinned versions,

Let's build the Dockerfile you will some something like:

```
Downloading torch-1.7.1-cp39-cp39-manylinux1_x86_64.whl (776.8 MB)
```

Wait! 776.8 MB?! Exactly, now we are trying to install PyTorch **with** CUDA. If you check the [PyTorch site](https://pytorch.org/), you'll see that the installation on Linux vs. Mac needs different versions.

Ok, the PyTorch site tells us to specify the version with `+cpu` to install it on Linux. We can try that:

```
# requirements.in
# file in macOS
torch==1.7.1+cpu
torchvision==0.8.2+cpu
```

We run again our `pip-compile` command and... surprise!

```
pip._internal.exceptions.DistributionNotFound: No matching distribution found for torchvision==0.8.2+cpu (from -r requirements.in (line 2))
```

The problem is that this version is for Linux, not macOS. There are some [GitHub](https://github.com/jazzband/pip-tools/issues/1114) [issues](https://github.com/pypa/pipenv/issues/4504) open about this bug, and so far, I have not found how to solve it.

Maybe we can run the installation of PyTorch as a separate step in our Dockerfile. Let's add this line:

```docker
RUN pip install torch==1.7.1+cpu
```

Build it, and... another error!

```
# error building Dockerfile
ERROR: Could not find a version that satisfies the requirement torch==1.7.1+cpu
ERROR: No matching distribution found for torch==1.7.1+cpu
```

It can't find the appropriate version. The solution for this is using the `--find-links` flag.

Thanks to [this Stack Overflow answer](https://stackoverflow.com/a/61742742) I learned how to specify that inside a `requirements.txt/.in` file:

```
# requirements.in
# file in macOS
--find-links https://download.pytorch.org/whl/torch_stable.html
torch
torchvision
```

However, that won't give us the versions with `+cpu`. We can try:

```
# requirements.in
# file in mac=S
--find-links https://download.pytorch.org/whl/torch_stable.html
torch==1.7.1+cpu
torchvision==0.8.2+cpu
```

But it will try to find that packages for macOS, which don't exist.

We have "quick and dirty" a workaround for the problem, adding this to our Dockerfile:

```docker
RUN pip install --find-links https://download.pytorch.org/whl/torch_stable.html torch==1.7.1+cpu torchvision==0.8.2+cpu
```

But now our dependencies management is becoming problematic. We need to find a different solution.

We could consider exporting the whole conda environment with `conda env export --no-build --name tester > env.yml` and using conda inside our docker. For that, we must install the `cpuonly` package. With that package installed, torch will work in macOS and in Linux, it will install the CPU versions. Regardless, porting conda environments across operating systems has a ton of problems. We could use `--from-history` but if we did not install dependencies with a specific version, it will create an environment file without versions.

There are [libraries](https://github.com/jamespreed/conda-minify) to help, but I don't want to install something else. We can use some conda functionalities to write a short python script that will clean our environment file. We will need to install `pyyaml` to read the exported conda environment. We can export it as `json` but then we would need to write it as `yaml` (conda can't create and environment from a `json` file).


```python
# conda_cleaner.py
from pathlib import Path
import re
import yaml
import subprocess

# load our original requirements.in files
# split and clean it
r = [s.strip() for s in Path("requirements.in").read_text().split("\n") if s != ""]
# ['numpy', 'pandas', 'fastapi', 'pytorch', 'torchvision']

pat = re.compile("|".join(r))
# re.compile(r'numpy|pandas|fastapi|pytorch|torchvision', re.UNICODE)

env_dict = yaml.full_load(
    subprocess.run(
        ["conda", "env", "export", "--no-build", "--name", "tester"],
        capture_output=True,
    ).stdout
)

clean_deps = [dep for dep in env_dict["dependencies"] if pat.search(dep)]

print(f"Keeping dependencies:\n{clean_deps}")
env_dict["dependencies"] = clean_deps
print("Removing prefix")
del env_dict["prefix"]

Path("docker_env.yaml").write_text(yaml.dump(env_dict))
```

Run `python3 conda_cleaner.py`. Our environment definition now looks like:

```yaml
channels:
- pytorch
- conda-forge
- defaults
dependencies:
- cpuonly=1.0
- fastapi=0.63.0
- numpy=1.19.5
- pandas=1.2.0
- pytorch=1.7.1
- torchvision=0.8.2
name: tester
```

Finally, we can use [micromamba](https://github.com/mamba-org/mamba#micromamba) to create a docker image:

```docker
FROM bitnami/minideb:buster

# Use bash in RUN commands and make sure bashrc is sourced when executing commands with /bin/bash -c
# Needed to have the micromamba activate command configured etc.
# from: https://gist.github.com/wolfv/fe1ea521979973ab1d016d95a589dcde#gistcomment-3525280
# Install basic commands and mamba

RUN install_packages wget tar bzip2 ca-certificates bash
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV ~/.bashrc

RUN wget -qO- https://micromamba.snakepit.net/api/micromamba/linux-64/latest | tar -xvj bin/micromamba --strip-components=1 && \
        ./micromamba shell init -s bash -p ~/micromamba

COPY ./docker_env.yaml .
RUN micromamba create -f ./env.yaml -y

ENTRYPOINT micromamba activate tester && python -c "import torch; print('success!')"
```

But... oh no!

```
# Installing:
# ...
 cudatoolkit         11.0.221  h6bb024c_0                       pkgs/main/linux-64       623 MB
 # ...
```
 
It's installing CUDA again.
 
Ok. Little detour. I cancelled the building of that Dockerfile. Here I started going crazy, I tried tons of different ways of building my Dockerfile and my `docker_env.yaml`. I think I spent more than 4 hours on it, only to later find this:

* [https://github.com/mamba-org/mamba/issues/336](https://github.com/mamba-org/mamba/issues/336)
* [https://github.com/pytorch/pytorch/issues/40213](https://github.com/pytorch/pytorch/issues/40213)

When I teach Python courses I repeat the same thing over and over, *"Programming is more about searching for the correct information than knowing the syntax by heart"*. Well, now I'm telling that to myself too.

Anyway, getting back to what we were doing, we need to find a way to automate this. We know that `pip-compile` kind of works, we are just missing `+cpu` at the end of each dependency, why don't we use python again?

```python
# cpu_fixer.py
import re
from pathlib import Path

data = Path("requirements.txt").read_text()
pat = re.compile(r"torch\w*\=\=\d.*\d")

new_data = []

for l in data.split("\n"):
    if pat.match(l):
        new_data.append(l + "+cpu")
    else:
        new_data.append(l)


Path("requirements.txt").write_text("\n".join(new_data))
```

That script will replace `torch==1.7.1` with `torch==1.7.1+cpu` and `torchvision==0.8.2` `torchvision==0.8.2+cpu`. We could achieve the same using `re.sub` but I'll leave it like that.

Just kidding, we can do it better like this:

```python

```

Let's try now, I've modified the entrypoint of the Dockerfile to import torch instead of numpy:

```docker
FROM python:3.7-slim-buster
COPY requirements.txt .
RUN pip install -r requirements.txt
ENTRYPOINT python -c "import torch; print('working!!')"
```

IT'S WORKING!! Sorry for the euphoria, when I started writing about this I didn't think it would take me.

**What we learned:**

* Use whatever you want to create your environment
* Mamba is amazing!
* Pip-tools is amazing! The good thing about pip-tools is that it does not "locks" you into any dependency manager, we can use conda/mamba and then compile the requirements with pip-tools so that we can just `pip install` in our Dockerfile.
* Searching for open GitHub issues before spending hours trying 100 things is highly recommended.


# About the workflow

This article was initially about workflows. As I said, now I use venv + pip-tools, but I'm enjoying using mamba to manage local environments. Now I'm also using [pyenv](https://github.com/pyenv/pyenv) to manage Python versions. If I move to mamba I won't need pyenv.