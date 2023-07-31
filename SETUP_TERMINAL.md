# Terminal Setup on Apple Silicon

## Terminals for Native ARM64 or Intel x86_64 Architectures

### Native ARM64 Terminal

For all native setup, use a native Terminal, iTerm or iTerm2 terminal to install software with native arm64 binary support.  In a native terminal, you should get this response from `arch`

```sh
$ arch
arm64
$ uname -m
arm64
```

### Intel Compatible Terminal with Rosetta

- go to Applications and find iTerm or iTerm2 application
- right-click and choose “Duplicate”
- rename the clone to “iTerm-Intel” or “iTerm2-Intel”
- right-click and choose “Get Info”
- Click on the checkbox to “Open Using Rosetta”
- Close the info dialog box and start the intel terminal

If it is not already installed, this could prompt to Rosetta.  For more information, see this apple support issue:
- [If you need to install Rosetta on your Mac - Apple Support](https://support.apple.com/en-us/HT211861)

All further steps should use the intel-compatible terminal to install additional software.  In an intel-compatible terminal, you should get this response from `arch`

```sh
$ arch
i386
$ uname -m
x86_64
```

## Shell Configuration for Different Architectures

To support both `arm64` and `x86_64` installations, the ZSH init script can be setup to display the
architecture.

```sh
# ~/.zshrc file

export SHELL_ARCH="$(uname -m)"
echo "=========== ${SHELL_ARCH} ============"

```

### Completion on ZSH

Use brew to install bash and zsh completion packages.  Update `~/.zshrc`
to enable completions:

```sh
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit
    compinit
fi
```

### Optional Starship Configuration

Display the architecture (`arm64` or `x86_64`) of the current shell in your prompt
using [Starship](https://starship.rs/). Add this to your `~/.config/starship.toml`:

```toml
# ~/.config/starship.toml

[env_var]
variable = "SHELL_ARCH"
style = "bold yellow"
format = "[$env_value]($style) "
```

### Intel-compatible terminal in IDEs

#### Intel-compatible terminal in VSCode

On Apple Silicon laptops, VSCode can use rosetta for the integrated terminal.  
This can be important for python development to get packages installed with `x86_64` binaries.

To create a custom VSCode Terminal Profile for using Rosetta on Apple Silicon, add these settings:

```json
{
  "terminal.integrated.profiles.osx": {
    "rosetta": {
      "path": "arch",
      "args": ["-x86_64", "zsh", "-l"],
      "overrideName": true
    }
  },
  "terminal.integrated.defaultProfile.osx": "rosetta"
}
```

#### Intel-compatible terminal in PyCharm

You can configure the terminal shell in `Preferences | Tools | Terminal` and set the `Shell Path:` like so:

```sh
env /usr/bin/arch -x86_64 /bin/zsh --login
```

### Docker Default Architecture

```sh
# ~/.zshrc file

if [ "$(uname -m)" = "x86_64" ]; then
    export DOCKER_DEFAULT_PLATFORM=linux/amd64
fi
```
