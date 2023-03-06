# Mac

Before you can use this, you'll need to install some things:

## Install Nix

We're gonna need Nix to install other packages.
Make sure to follow any instructions given by the installer.

```sh
sh <(curl -L https://nixos.org/nix/install)
```

Check if you have access to packages:

```sh
nix-env -qaP
```

If you don't, you'll need to add nixpkgs:

```sh
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
```

We'll also need to install nix-darwin:

```sh
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

This may require us to move `/etc/nix/nix.conf` if you see the following
warning:

> warning: not linking environment.etc."nix/nix.conf" because /etc/nix/nix.conf
> exists, skipping...

Just run:

```sh
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf_old
```

With `nix-darwin` installed, we'll be able to declaratively configure macOS
using the files in this repo.

## Install Homebrew

Homebrew is also used see (see [ARCHITECTURE.md](#ARCHITECTURE.md)), but cannot
yet be installed through Nix.

```sh
/bin/bash -c "$(curl -fsSL \
 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
