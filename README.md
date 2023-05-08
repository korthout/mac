# Mac

This repo contains the dotfiles and installed packages of my Mac.
Homebrew is the main way to manage packages from this repo.
An overview of all installed packages can be found in `Brewfile` (the exact versions are specified in `Brewfile.lock.json`).
Originally, I looked into using Nix and nix-darwin to manage packages, but this was too cumbersome compared to Brew.

This repo should be used as a bare git repository to work on the `~` home folder without messing with git repos existing in sub folders.

## Fresh install

Before you can use the rest of this repo, you'll need to install some things:

### Bare repository clone and checkout

To start using this repo on a new machine, we need to run the following in a new shell.
This idea was taken from: https://www.atlassian.com/git/tutorials/dotfiles.

```sh
git clone --bare git@github.com:korthout/mac.git $HOME/.cfg
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout
config config status.showUntrackedFiles no
```

### Install Homebrew

You can install Homebrew pretty in an unsafe way.
If you want to protect yourself more, first download the file, verify a checksum, and inspect the contents before executing it.

```sh
/bin/bash -c "$(curl -fsSL \
 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install Rosetta

You may also need to install Rosetta on your machine to be able to use non-arm binaries.

```sh
softwareupdate --install-rosetta --agree-to-license
```

## Usage

Install and update packages

```sh
brew bundle --verbose
config commit -a -m 'Update packages'
config push
```

Dump newly installed packages into Brewfile

```sh
brew bundle dump --force --describe
config commit -a -m 'Add new package'
config push
```

## Additional installations

Some installations require manual effort.

### VS Code Extensions

Dump extensions into a file

```sh
code --list-extensions > vscode-extensions.list
```

Install extensions

```sh
cat vscode-extensions.list | xargs -L 1 code --install-extension
```

> Source: https://stackoverflow.com/a/54467390
