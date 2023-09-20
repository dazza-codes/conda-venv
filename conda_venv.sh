#!/usr/bin/env bash

# Copyright 2019-2023 Darren Weber
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Source this file from ~/.bashrc, ~/.zshrc or a compatible shell-init, such
# as copy the file to /etc/profile.d/

# https://python-release-cycle.glitch.me/
# https://endoflife.date/python
# Declare a default python version to support; this could be the lowest
# version that is still in active maintenance or it could match the current
# default version used in Homebrew or an Ubuntu LTS release.
export PYTHON_SUPPORT_VERSION=${PYTHON_SUPPORT_VERSION:-3.10}

# The conda-venv-py?? functions could be run anytime there is a patch release to
# any python version, updates to conda or anytime a clean conda env is required
# with a non-default python version.

# Support for Different Architectures
# https://stackoverflow.com/questions/33709391/using-multiple-python-engines-32bit-64bit-and-2-7-3-5/58014896#58014896

conda-subdir () {
    if [ $(uname) = "Darwin" ]; then
        if [ $(uname -m) = "x86_64" ]; then
            echo "osx-64"
        fi
        if [ $(uname -m) = "arm64" ]; then
            echo "osx-arm64"
        fi
    fi
    if [ $(uname) = "Linux" ]; then
        if [ $(uname -m) = "x86_64" ]; then
            echo "linux-64"
        fi
        if [ $(uname -m) = "aarch64" ]; then
            echo "linux-arm64"
        fi
    fi
    # TODO: support windows?
}

export CONDA_SUBDIR=$(conda-subdir)

conda-venv-base () {
    py_ver="${1:-${PYTHON_SUPPORT_VERSION}}"
    conda deactivate
    conda env remove -n py"${py_ver}" || true

    conda create -y -n py"${py_ver}" python="${py_ver}" -c conda-forge \
    && conda activate py"${py_ver}" \
    && conda config --env --add channels conda-forge \
    && conda config --env --set channel_priority strict \
    && conda config --env --set subdir ${CONDA_SUBDIR}

    # ?? conda env config vars set CONDA_SUBDIR=osx-arm64
}

conda-venv-py3.8 () {
    conda-venv-base 3.8
}

conda-venv-py3.9 () {
    conda-venv-base 3.9
}

conda-venv-py3.10 () {
    conda-venv-base 3.10
}

conda-venv-py3.11 () {
    conda-venv-base 3.11
}

# declare some useful aliases to use a conda python version;
# these aliases simply try to activate an existing env.
alias conda-py3.8='conda deactivate; conda activate py3.8'
alias conda-py3.9='conda deactivate; conda activate py3.9'
alias conda-py3.10='conda deactivate; conda activate py3.10'
alias conda-py3.11='conda deactivate; conda activate py3.11'

conda-project () {
    # The project name is defined by CONDA_ENV or the current working directory
    project=${CONDA_ENV:-$(pwd)}
    basename "${project}"
}

conda-venv-activate () {
    # try to activate a conda environment with the name of
    # the current directory (often this is a project name).
    wd=$(conda-project)
    conda deactivate
    conda activate "$wd"
}

conda-venv-create () {
    # create and activate a conda environment with the name
    # of the current directory (often this is a project name).
    py_ver="${1:-${PYTHON_SUPPORT_VERSION}}"
    wd=$(conda-project)
    conda deactivate

    conda create -n "${wd}" python="${py_ver}" \
      --channel conda-forge --override-channels \
    && conda activate "${wd}" \
    && conda config --env --add channels conda-forge \
    && conda config --env --set channel_priority strict \
    && conda config --env --set subdir ${CONDA_SUBDIR}
}

conda-venv-remove () {
    # try to activate a conda environment with the name of
    # the current directory (often this is a project name).
    wd=$(conda-project)
    conda deactivate
    conda env remove -n "$wd"
}

conda-venv () {
    # create and activate a conda environment with the name
    # of the current directory (often this is a project name).
    py_ver="${1:-${PYTHON_SUPPORT_VERSION}}"
    wd=$(conda-project)

    if conda env list | grep -E "^${wd}\s+" > /dev/null; then
        conda-venv-activate
    else
        conda-venv-create "${py_ver}"
    fi
    command -v poetry > /dev/null
    if command -v python > /dev/null; then
        python --version
    fi
}

conda-install () {
    root_url="https://github.com/conda-forge/miniforge/releases/latest/download"
    installer="Miniforge3-$(uname)-$(uname -m).sh"
    install_script="/tmp/${installer}"
    echo "Downloading: ${root_url}/${installer}"
    curl -L -s "${root_url}/${installer}" > "$install_script"

    echo "To run the downloaded installer: sudo /bin/bash $install_script -f -b"
    if [ $(uname -m) = "x86_64" ]; then
      echo "Optional installation to custom path:  sudo /bin/bash $install_script -p /usr/local/miniforge3 -f -b"
      echo "Set permissions on the installation:   sudo chown -R $USER:admin /usr/local/miniforge3"
    fi
    if [ $(uname -m) = "arm64" ]; then
      echo "Optional installation to custom path:  sudo /bin/bash $install_script -p /opt/miniforge3 -f -b"
      echo "Set permissions on the installation:   sudo chown -R $USER:admin /opt/miniforge3"
    fi
}

mamba-install () {
    root_url="https://github.com/conda-forge/miniforge/releases/latest/download"
    installer="Mambaforge-$(uname)-$(uname -m).sh"
    install_script="/tmp/${installer}"
    echo "Downloading: ${root_url}/${installer}"
    curl -L -s "${root_url}/${installer}" > "$install_script"

    echo "To run the downloaded installer:       sudo /bin/bash $install_script -f -b"
    if [ $(uname -m) = "x86_64" ]; then
      echo "Optional installation to custom path:  sudo /bin/bash $install_script -p /usr/local/mambaforge -f -b"
      echo "Set permissions on the installation:   sudo chown -R ${USER}:staff /usr/local/mambaforge"
    fi
    if [ $(uname -m) = "arm64" ]; then
      echo "Optional installation to custom path:  sudo /bin/bash $install_script -p /opt/mambaforge -f -b"
      echo "Set permissions on the installation:   sudo chown -R ${USER}:staff /opt/mambaforge"
    fi
}

_conda-venv-completions () {
    command_options="3.8 3.9 3.10 3.11"
    COMPREPLY=($(compgen -W "${command_options}" "${COMP_WORDS[1]}"))
}

complete -F _conda-venv-completions conda-venv
complete -F _conda-venv-completions conda-venv-base
complete -F _conda-venv-completions conda-venv-create
