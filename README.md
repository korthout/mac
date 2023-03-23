# Mac

Homebrew is the main way to manage packages from this repo.
An overview of all installed packages can be found in `Brewfile` (the exact versions are specified in `Brewfile.lock.json`).

Originally, I looked into using Nix and nix-darwin to manage packages, but this was too cumbersome compared to Brew.

Before you can use the rest of this repo, you'll need to install some things:

## Install Homebrew

You can install Homebrew pretty in an unsafe way.
If you want to protect yourself more, first download the file, verify a checksum, and inspect the contents before executing it.

```sh
/bin/bash -c "$(curl -fsSL \
 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
