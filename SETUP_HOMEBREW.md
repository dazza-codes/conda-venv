# Homebrew Setup on Apple Silicon

See [Terminal](SETUP_TERMINAL.md) for details on arm64 and x86_64 terminal setup.

## Native ARM64 Setup

Open a native terminal (“iTerm”).  The home-brew installer will choose a different installation path that depends on the architecture:
- `/usr/local` for macOS Intel
- `/opt/homebrew` for Apple Silicon

In this installation, using a native terminal, it should choose to install into the `/opt/homebrew` path.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```sh
$ which brew
/opt/homebrew/bin/brew
```

## Intel Compatible Setup

Open an intel-compatible terminal (“iTerm2-Intel”).  The home-brew installer will choose a different installation path that depends on the architecture:
- `/usr/local` for macOS Intel
- `/opt/homebrew` for Apple Silicon

In this installation, using a rosetta terminal, it should choose to install into the `/usr/local` path.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```sh
$ which brew
/usr/local/bin/brew
```

As an optional step, create an alias for this intel-compatible installation of brew:

```sh
# ~/.zshrc file

# Multiple Homebrews on Apple Silicon
# Homebrew setup, based on both intel-rosetta and arm64 installations
# https://stackoverflow.com/questions/64951024/how-can-i-run-two-isolated-installations-of-homebrew
alias ibrew='arch --x86_64 /usr/local/Homebrew/bin/brew'
```

## Shell Configuration for Multiple Installations of Homebrew

To support both `arm64` and `x86_64` installations for brew, the ZSH init script can be setup to configure brew with `arch` specific paths.

```sh
# ~/.zshrc file

if [ "$(uname -m)" = "arm64" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi
```
