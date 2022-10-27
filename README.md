# conda-venv

Bash functions for convenient conda env project management.  This is a thin
wrapper on the `conda` CLI, it should be compatible with most recent versions of
conda and upgrades that maintain the current CLI commands.

Like most tools to provide a virtual environment, these bash functions are only
intended to create a `conda env`.  The purpose of the wrappers is to:

- use a default python version (that might not be the default conda version) and 
- to auto-detect the name for an environment based on the current working
  directory.

It is opinionated about configuring an environment to use conda-forge packages.
This can avoid mixing packages from multiple repository sources, which often
results in incompatible packages or broken packages.  The bash functions do
_not_ provide any commands to install any packages.

## Getting Started

Source the `conda_venv.sh` file in `~/.bashrc` or similar shell-init, such
as copy the file to `/etc/profile.d/conda_venv.sh`.

For example:

```sh
sudo curl -sSL https://raw.githubusercontent.com/dazza-codes/conda-venv/main/conda_venv.sh > /etc/profile.d/conda_venv.sh
```

For a user installation, use `~/bin/conda_venv.sh`.  For example:

```sh
curl -sSL https://raw.githubusercontent.com/dazza-codes/conda-venv/main/conda_venv.sh > ~/bin/conda_venv.sh
```

Ensure the shell init includes `~/bin/` in the `$PATH` (it often does already).
Add the following to `~/.bashrc` or `~/.zshrc` (or similar shell init file).

```sh
if [ -f ~/bin/conda_venv.sh ]; then
    source ~/bin/conda_venv.sh
fi
```

For ZSH, the bash completion support could be enabled using

```sh
autoload bashcompinit && bashcompinit
if [ -f ~/bin/conda_venv.sh ]; then
    source ~/bin/conda_venv.sh
fi
```

## conda-install

The `conda-install` function will start to install the latest miniconda3 on OSX or Linux.
Follow the prompts from the conda installer.

## Project conda-venv

The most common use of these bash functions is to activate a project conda env
with a default python version or a project-specific python version.  For example,
the common utility is to change to a git working directory and activate a conda
env for that project.  For example:

```sh
cd ~/src/project-a
conda-venv  # to activate or create 'project-a' env

# to deactivate 'project-a' and activate or create 'project-b' env
cd ~/src/project-b
conda-venv
```

The `conda-venv` function will use a project name to either activate an existing
conda env or create it.  The project name is defined by `CONDA_ENV` environment
variable or the current working directory (i.e. `basename $(pwd)`).

```sh
mkdir -p ~/tmp/conda-project
cd ~/tmp/conda-project

# creates conda env 'conda-project'
# with a default $PYTHON_SUPPORT_VERSION
conda-venv

# creates conda env 'conda-project' with python 3.9;
# if the conda env was created with a different python
# version, it is not removed.
conda-venv 3.9

# to clean a conda env, use
conda-venv-remove
```

To override the use of the project directory, use the `CONDA_ENV` environment
variable.

### conda-forge for projects

The intention of this project is to only manage a conda env with any python
version.  There is no intention to add any functionality to manage any package
installations.  However, the project conda env is created with options that will
get packages from conda-forge, i.e.

```sh
conda create --channel conda-forge --override-channels # etc
conda activate # project
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict
```

## Default python version

A default python version is declared using, e.g.

```sh
export PYTHON_SUPPORT_VERSION=3.7
```

If you prefer to use a different default version, then edit that env-var in
`~/bin/conda_venv.sh` or override it in a bash init.  The value set in that file
is not automatically updated.

This is based on the oldest python version in support.

- [Status of Python branches](https://devguide.python.org/#status-of-python-branches)
- [Status of Python chart](https://python-release-cycle.glitch.me/)

It declares a minimal python version to support; this is the lowest
version that is still in active maintenance.  This might not be the default
python version for conda.  As a python version approaches EOL support,
bumping this to the next lowest version can assist migration strategies.

## Creating a conda env with any python version

The `conda-venv-base` function will recreate a conda env with the python
version.  This can be run anytime there is a patch release to any python
version, updates to conda or anytime a clean conda env is required with a
non-default python version.  

```sh
conda-venv-base 3.6  # creates py3.6
conda-venv-base 3.7  # creates py3.7
conda-venv-base 3.8  # creates py3.8
conda-venv-base 3.9  # creates py3.9
conda-venv-base 3.10  # creates py3.10
```

The `conda_venv.sh` script provides some sample bash aliases for an existing
conda env with a python version, e.g.:

```sh
alias conda-py3.6='conda deactivate; conda activate py3.6'
alias conda-py3.7='conda deactivate; conda activate py3.7'
alias conda-py3.8='conda deactivate; conda activate py3.8'
alias conda-py3.9='conda deactivate; conda activate py3.9'
alias conda-py3.10='conda deactivate; conda activate py3.10'
```

## Apple Silicon and Intel-Compatible Terminals

Clone the “iTerm” or “iTerm2” applications to Open with Rosetta

- go to Applications and find iTerm or iTerm2 application
- right-click and choose “Duplicate”
- rename the clone to “iTerm-Intel” or “iTerm2-Intel”
- right-click and choose “Get Info”
- Click on the checkbox to “Open Using Rosetta”
- Close the info dialog box and start the intel terminal

If it is not already installed, this could prompt to install Rosetta.  For more information, see this apple support issue:
- [If you need to install Rosetta on your Mac - Apple Support](https://support.apple.com/en-us/HT211861)

In an intel-compatible terminal, you should get this response from `arch`

```sh
$ arch
i386
```

## Install miniforge for arm64 and x86_64 architectures

Miniforge can be installed for both arm64 and x86_64 architectures.  The following notes are adapted from this article:
https://towardsdatascience.com/how-to-install-miniconda-x86-64-apple-m1-side-by-side-on-mac-book-m1-a476936bfaf0

### Step 1 - arm64 architecture

Use a native terminal.

```sh
mkdir -p ~/tmp
cd ~/tmp
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh
sudo /bin/bash Miniforge3-MacOSX-arm64.sh -p /opt/miniforge3 -f -b
sudo chown -R "$USER":admin /opt/miniforge3
```

If a specific version is required, find the required assets from the 
[miniforge releases](https://github.com/conda-forge/miniforge/releases), e.g.

```sh
mkdir -p ~/tmp
cd ~/tmp
wget https://github.com/conda-forge/miniforge/releases/download/4.14.0-2/Miniforge3-4.14.0-2-MacOSX-arm64.sh
sudo /bin/bash Miniforge3-4.14.0-2-MacOSX-arm64.sh -p /opt/miniforge3 -f -b
sudo chown -R "$USER":admin /opt/miniforge3
```

### Step 2 - x86_64 architecture

Use a rosetta terminal.

```sh
mkdir -p ~/tmp
cd ~/tmp
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh
sudo /bin/bash Miniforge3-MacOSX-x86_64.sh -p /usr/local/miniforge3 -f -b
sudo chown -R "$USER":admin /usr/local/miniforge3
```

If a specific version is required, find the required assets from the 
[miniforge releases](https://github.com/conda-forge/miniforge/releases), e.g.

```sh
mkdir -p ~/tmp
cd ~/tmp
wget https://github.com/conda-forge/miniforge/releases/download/4.14.0-2/Miniforge3-4.14.0-2-MacOSX-x86_64.sh
sudo /bin/bash Miniforge3-4.14.0-2-MacOSX-x86_64.sh -p /usr/local/miniforge3 -f -b
sudo chown -R "$USER":admin /usr/local/miniforge3
```

### Step 3 - Configure ZSH for multiple installations of miniforge

The ZSH init script can be setup to configure conda with `arch` specific paths.

```sh
# ~/.zshrc file
if [ "$(arch)" = "arm64" ]; then
    eval "$(/opt/miniforge3/bin/conda shell.zsh hook)"
else
    eval "$(/usr/local/miniforge3/bin/conda shell.zsh hook)"
fi
```

## LICENSE

```text
Copyright 2019-2022 Darren Weber

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
