# Mac

This repo contains the dotfiles and installed packages of my Mac.
Homebrew is the main way to manage packages from this repo.
An overview of all installed packages can be found in `Brewfile.work` and `Brewfile.personal` (the exact versions are specified in `Brewfile.work.lock.json` and `Brewfile.personal.lock.json`, respectively).
Originally, I looked into using Nix and nix-darwin to manage packages, but this was too cumbersome compared to Brew.

This repo should be used as a bare git repository to work on the `~` home folder without messing with git repos existing in sub folders.

## Fresh install

Before you can use the rest of this repo, you'll need to install some things:

### Install Command Line Tools

In order to use `git` we'll need the Command Line Tools.

```sh
xcode-select --install
```

### Bare repository clone and checkout

To start using this repo on a new machine, we need to run the following in a new shell.
This idea was taken from: https://www.atlassian.com/git/tutorials/dotfiles.

```sh
git clone --bare https://github.com/korthout/mac.git $HOME/.cfg
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

### Set this machine's context

Each machine is permanently either `work` or `personal`. `update`,
`brew-install`, and `brew-uninstall` all read this from a local,
untracked marker file and refuse to run without it, so set it now,
before the first `update`.

The checkout above wrote `~/.zshrc`, which is what sets
`$XDG_CONFIG_HOME` — open a new shell (or `source ~/.zshrc`) first so
it's actually set in your current one:

```sh
mkdir -p "$XDG_CONFIG_HOME/homebrew"
echo work > "$XDG_CONFIG_HOME/homebrew/context"      # or: echo personal > ...
```

This file lives outside version control — untracked files in this
repo are already hidden from `config status` — and is never synced;
every machine sets it independently.

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

### Install and update packages

```sh
update
```

Installs and updates the packages shared across every machine, plus this
machine's own context. Unchanged day-to-day: no flags, no prompts about
context.

### Install a package

```sh
brew-install <package>
```

Installs the package and records it against this machine's context. If it
looks like something you'd want everywhere, you'll be asked:

> Do you want to share this?

- **No** (default) — stays recorded against this machine's context only.
- **Yes** — recorded as shared: added to *both* Brewfiles, so every
  machine's next `update` picks it up. Also how you promote an existing
  work-only or personal-only package to shared — just re-run
  `brew-install` on it.

Installed something by hand with plain `brew install`? Run `brew-install
<package>` on it too, even though it's already installed — it's a safe
no-op reinstall that records it in the Brewfile and asks the share
question.

### Uninstall a package

```sh
brew-uninstall <package>
```

Uninstalls the package and removes its record. If the package was shared
(listed in both Brewfiles), you'll be asked what should happen to the
*other* machines that still expect it:

- **Remove entirely** — dropped from both Brewfiles.
- **Keep it for the other side** (default) — removed from this machine's
  file only; the other context keeps it untouched.

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

### Stats config

These can be exported using:

```sh
defaults read eu.exelban.Stats > ~/configs/stats.json
```

And can be imported using:

```sh
defaults import eu.exelban.Stats ~/configs/stats.json
```

### Rectangle config

The config can be imported and exported using the Rectangle Settings UI.

- `configs/RectangleConfig.json`

### iTerm config

The config can be imported and exported using the iTerm Settings UI.

- Profile: `config/iterm2-profile.json`
- Keymap: `config/iterm2.itermkeymap`
