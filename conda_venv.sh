#!/usr/bin/env bash

# Copyright 2019-2022 Darren Weber
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
export PYTHON_SUPPORT_VERSION=${PYTHON_SUPPORT_VERSION:-3.9}

# The conda-venv-py?? functions could be run anytime there is a patch release to
# any python version, updates to conda or anytime a clean conda env is required
# with a non-default python version.

# Support for Different Architectures
# https://stackoverflow.com/questions/33709391/using-multiple-python-engines-32bit-64bit-and-2-7-3-5/58014896#58014896

conda-subdir () {
    if [ $(uname) = "Darwin" ]; then
        if [ $(uname -m) = "x86_64" ]; then
            echo "osx-64"
        else
            if [ $(uname -m) = "arm64" ]; then
                echo "osx-arm64"
            fi
        fi
    else
        if [ $(uname) = "Linux" ]; then
            if [ $(uname -m) = "x86_64" ]; then
                echo "linux-64"
            else
                if [ $(uname -m) = "aarch64" ]; then
                    echo "linux-arm64"
                fi
            fi
        else
            # TODO: support windows?
            exit 1
        fi
    fi
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

conda-venv-py3.7 () {
    conda-venv-base 3.7
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

# declare some useful aliases to use a conda python version;
# these aliases simply try to activate an existing env.
alias conda-py3.7='conda deactivate; conda activate py3.7'
alias conda-py3.8='conda deactivate; conda activate py3.8'
alias conda-py3.9='conda deactivate; conda activate py3.9'
alias conda-py3.10='conda deactivate; conda activate py3.10'

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
    python --version
}

conda-install () {
    # Support OSX and Linux - a Windows user can add support for it later
    if [ $(uname) = "Darwin" ]; then
        if [ $(uname -m) = "x86_64" ]; then
            installer="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh"
        else
            if [ $(uname -m) = "arm64" ]; then
                installer="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh"
            fi
        fi
    else
        if [ $(uname) = "Linux" ]; then
            if [ $(uname -m) = "x86_64" ]; then
                installer="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
            else
                if [ $(uname -m) = "aarch64" ]; then
                    installer="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh"
                fi
            fi
        else
            # TODO: support windows?
            exit 1
        fi
    fi

    install_script="/tmp/$(basename $installer)"
    curl --silent $installer > "$install_script"
    echo "Run the downloaded installer: ${install_script}"
}

_conda-venv-completions () {
    command_options="3.7 3.8 3.9 3.10"
    COMPREPLY=($(compgen -W "${command_options}" "${COMP_WORDS[1]}"))
}

complete -F _conda-venv-completions conda-venv
complete -F _conda-venv-completions conda-venv-base
complete -F _conda-venv-completions conda-venv-create
