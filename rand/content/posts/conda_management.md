+++
title = "Conda management"
date = "2020-02-21"
author = "Ricardo"
categories = ["conda", "environments"]
tags = ["conda", "environment", "python"]
thumbnail = "img/sharing/conda_management.jpg"
+++


Manage conda environments and Jupyterlab easily.
<!--more-->

**TL;DR** Use [this](https://github.com/polyrand/scripts/blob/master/condacreate_dev.sh) script to create a base conda environment with Jupyterlab and some plugins, and [this](https://github.com/polyrand/scripts/blob/master/condacreate.sh) to create new environments and make them available when launching Jupyter.

I used to have a default script to create a conda environment, in that script I would install al the packages I consider basic, plus Jupyterlab and some plugins. Yes a new fresh Jupyterlab+plugins for every environment.

A few days ago I read [this tweet by Vicki Boykis](https://twitter.com/vboykis/status/1229813718776786944) and [one of the answers from Peter Baumgartner](https://twitter.com/pmbaumgartner/status/1229880784342917122) and decided to change my workflow a little bit. Now I use the 2 scripts I linked above, and I will go through explaining what they do. Hopefully you can also learn a bit about conda too.

[condacreate_dev.sh](https://github.com/polyrand/scripts/blob/master/condacreate_dev.sh): this first one is used to create a base environment that will hold jupyterlab, and the package [nb_conda_kernels](https://github.com/Anaconda-Platform/nb_conda_kernels) which *enables a Jupyter Notebook or JupyterLab application in one conda environment to access kernels for Python, R, and other languages found in other environments*.

```bash
conda create --name "$NAME" python="$VERSION"
```

With that we create a new conda environment with the name we want and a pyhon version, in my case I execute the script like: `./condacreate_dev.sh dev 3.7` and it creates an environment called "dev" using Python 3.7.

```sh
conda install -y --name "$NAME" -c conda-forge ipython jupyterlab nb_conda_kernels
```

Now we install the python packages I mentioned before. Using the flag `-y` we accept the installation by default so we don't need to interact with our terminalm the flag `--name` lets you execute the command in the environment with that name (in this case it's "dev").

Then I install the extensions I use:

```sh
conda run -n "$NAME" jupyter labextension install @jupyterlab/toc --no-build
conda run -n "$NAME" jupyter labextension install @jupyterlab/celltags --no-build
conda run -n "$NAME" jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build
conda run -n "$NAME" jupyter labextension install @ryantam626/jupyterlab_code_formatter --no-build
```

`conda run` executes a command, `-n` is the same as `--name`, the tag `--no-build` tells Jupyterlab to **not** rebuild itself after installing every extensions. Before knowing that tag existed I spent quite a lot of time creating new environments.

```sh
conda install -y --name "$NAME" -c conda-forge jupyterlab-git
conda install -y --name "$NAME" -c conda-forge jupyterlab_code_formatter
conda run -n "$NAME" jupyter serverextension enable --py jupyterlab_code_formatter
conda run -n "$NAME" jupyter lab build
```

Finally I install some more extensions and I rebuild Jupyterlab with the last command.

The last lines:

```sh
if [[ $3 == 'alias' ]]; then
    echo "alias $NAME='conda activate $NAME'" >> ~/dotfiles/.condalias
fi
```

With those I can create an alias with the same name of the environment to activate it, so if my initial command was `./condacreate_dev.sh dev 3.7 alias` it would have create an alias so that by running the command `dev` in my terminal would activate that environment.

[condacreate.sh](https://github.com/polyrand/scripts/blob/master/condacreate.sh): the second one creates a default environment with the base packages. At the end we run:

```sh
conda run -n "$NAME" ipython kernel install --user --name="$NAME"
```

And with that we register the environment to be used every time I run Jupyter.

Apart from that, I use a couple of bash aliases tha simplify the workflow a lot:

```sh
alias createpy='bash ~/Projects/scripts/condacreate.sh'
alias createdev='bash ~/Projects/scripts/condacreate_dev.sh'

alias lab='conda run -n dev jupyter lab'
alias blab='nohup conda run -n dev jupyter lab --browser firefox &>/dev/null &'
```

The first two are for creating the environments, the other are for running Jupyterlab from the base environment (called "dev"). The most special one is the last one, which runs Jupyterlab in the background so that it does not die if you mistakenly close the terminal.

My final workflow would be:

```sh
# create base env
createdev dev 3.7

# create env for nlp and make an alias called "nlp" to activate it
createpy nlp 3.7 alias

# activate that env
nlp

# and install whatever I need
conda install -c conda-forge spacy gensim 

# deactivate the environment
conda deactivate
```

And now from anywhere I can run `blab` to run Jupyterlab and create a new notebook using the environment called "nlp".

Lastly, you can run `jupyter kernelspec list` with the "dev" environment activated to list the registered kernels and `jupyter kernelspec uninstall <name>` to remove the kernel called `<name>`.

References:

* http://veekaybee.github.io/2020/02/18/running-jupyter-in-venv/
* https://twitter.com/pmbaumgartner/status/1229880784342917122
