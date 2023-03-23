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

## Install Rosetta

You may also need to install Rosetta on your machine to be able to use non-arm binaries.

```sh
softwareupdate --install-rosetta --agree-to-license
```

## Usage

Install and update packages

```sh
brew bundle --verbose
git commit -a -m 'Update packages'
git push
```

Dump newly installed packages into Brewfile

```sh
brew bundle dump --force --describe
git commit -a -m 'Add new package'
git push
```
