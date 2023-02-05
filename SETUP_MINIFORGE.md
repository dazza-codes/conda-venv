# Python Setup on Apple Silicon - Step by Step

See [Terminal](SETUP_TERMINAL.md) for details on arm64 and x86_64 terminal setup.

## Install miniforge for arm64 and x86_64 architectures

Miniforge can be installed for both arm64 and x86_64 architectures.  The following notes are adapted from this article:
https://towardsdatascience.com/how-to-install-miniconda-x86-64-apple-m1-side-by-side-on-mac-book-m1-a476936bfaf0

## Step 1 - arm64 architecture

Use a native terminal.

```sh
mkdir -p ~/tmp
cd ~/tmp
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh
bash Miniforge3-MacOSX-arm64.sh -p /opt/miniforge3 -f -b
```

If a specific version is required, find the required assets from the 
[miniforge releases](https://github.com/conda-forge/miniforge/releases), e.g.

```sh
mkdir -p ~/tmp
cd ~/tmp
wget https://github.com/conda-forge/miniforge/releases/download/4.14.0-2/Miniforge3-4.14.0-2-MacOSX-arm64.sh
sudo /bin/bash Miniforge3-4.14.0-2-MacOSX-arm64.sh -p /opt/miniforge3 -f -b
sudo chown -R "$USER":staff /opt/miniforge3
```

A similar approach works for `mambaforge` variants of conda.  For example:

```sh
mkdir -p ~/tmp
cd ~/tmp
wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Darwin-arm64.sh
sudo /bin/bash Mambaforge-Darwin-arm64.sh -p /opt/mambaforge -f -b
sudo chown -R "$USER":staff /opt/mambaforge
```

## Step 2 - x86_64 architecture

Use a rosetta terminal with the x86_64 architecture.  

```sh
mkdir -p ~/tmp
cd ~/tmp
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh
sudo /bin/bash Miniforge3-MacOSX-x86_64.sh -p /usr/local/miniforge3 -f -b
sudo chown -R "$USER":staff /usr/local/miniforge3
```

A similar approach works for `mambaforge` variants of conda.  For example:

```sh
mkdir -p ~/tmp
cd ~/tmp
wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Darwin-x86_64.sh
sudo /bin/bash Mambaforge-Darwin-x86_64.sh -p /usr/local/mambaforge -f -b
sudo chown -R "$USER":staff /usr/local/mambaforge
```

## Step 3 - Configure ZSH for multiple installations of miniforge

In anticipation of additional installations for intel-compatible miniforge (see below), the ZSH init script can be setup to configure conda with `arch` specific paths.

```sh
# ~/.zshrc file

if [ "$(uname -m)" = "arm64" ]; then
    eval "$(/opt/miniforge3/bin/conda shell.zsh hook)"
fi
if [ "$(uname -m)" = "x86_64" ]; then
    eval "$(/usr/local/miniforge3/bin/conda shell.zsh hook)"
fi
```

Similar configuration works for `mambaforge`, i.e.

```sh
# ~/.zshrc file

if [ "$(uname -m)" = "arm64" ]; then
    eval "$(/opt/mambaforge/bin/conda shell.zsh hook)"
fi
if [ "$(uname -m)" = "x86_64" ]; then
    eval "$(/usr/local/mambaforge/bin/conda shell.zsh hook)"
fi
```

## Step 4 - Disable the base activation

It's a good idea to disable the automatic activation of the conda `base` environment
when any shell starts.

```sh
conda config --set auto_activate_base false
```
