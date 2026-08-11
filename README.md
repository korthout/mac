# Mac

This repo contains the dotfiles and installed packages of my Mac.
Homebrew is the main way to manage packages from this repo.
An overview of all installed packages can be found in `Brewfile.work` and `Brewfile.personal`.
Versions are not pinned — each machine gets whatever Homebrew considers current at install time.
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
`$XDG_CONFIG_HOME` and puts `~/bin` on your `PATH`. Open a new shell (or
`source ~/.zshrc`) first — otherwise the variable below is empty, and
`update`/`brew-install`/`brew-uninstall` aren't found at all:

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

Installs everything listed in this machine's Brewfile — `Brewfile.work`
or `Brewfile.personal`, whichever the context says. Unchanged day-to-day:
no flags, no prompts about context.

There is no third "shared" file. A package is shared by being listed in
both Brewfiles, and `update` only ever reads one of them; it never
reconciles the two.

### Install a package

```sh
brew-install <package>
brew-install --cask <package>
```

Installs the package and records it against this machine's context. If it
looks like something you'd want everywhere, you'll be asked:

> Do you want to share 'jq'? [y/N]

- **No** (default) — stays recorded against this machine's context only.
- **Yes** — recorded as shared: added to *both* Brewfiles, so every
  machine's next `update` picks it up. Also how you promote an existing
  work-only or personal-only package to shared — just re-run
  `brew-install` on it.

Sharing also copies over the `tap` line a third-party package needs, so
the other machine can actually resolve it.

#### Packages from a third-party tap need their full name

```sh
brew-install --cask stablyai/orca/orca      # not: --cask orca
```

Homebrew resolves a bare name against its own taps first, and short names
collide: `orca` is a plotly image tool in `homebrew/cask`, unrelated to
`stablyai/orca/orca`. Given the bare name, these tools will faithfully
install and record the wrong package. Use the tap-qualified name for
anything not from `homebrew/core` or `homebrew/cask`.

Installed something by hand with plain `brew install`? Run `brew-install
<package>` on it too, even though it's already installed — it's a safe
no-op reinstall that records it in the Brewfile and asks the share
question. Same caveat: pass the tap-qualified name if it came from a
third-party tap.

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

The package has to actually be installed. `brew-uninstall` runs `brew
uninstall` first and stops there if that fails, so it can't be used to
drop a stale Brewfile entry for something already gone — edit the
Brewfile by hand for that.

Its `tap` line is left behind, on the assumption something else may still
need it.

### When these tools refuse

Both `brew-install` and `brew-uninstall` deliberately handle one package
at a time, and accept no flags beyond `--cask`/`--casks` and
`--formula`/`--formulae`:

- `brew-install jq ripgrep` — refused. Run them one at a time.
- `brew-install --HEAD foo` — refused. Flags that change *what* gets
  installed can't be expressed as a Brewfile line, so recording the
  package without them would misrepresent what's on disk.

If the final `config push` is rejected because another machine pushed
first, nothing is retried automatically — you'll be told to run:

```sh
config pull && config push
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
