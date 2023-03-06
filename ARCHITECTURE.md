# Architecture

Some design choices were made to construct this setup.

# Nix vs Homebrew

Nix is awesome to reliably install packages and using nix-darwin (or
home-manager) it is possible to configure the system declaratively.

Problems arrise when Nix is used to install graphical apps. The symlinks cannot
be picked up by Spotlight (and Alfred), many apps are not yet available as
macOS package, let alone for aarch64-darwin.

Homebrew can be used to install such apps rather easily through Casks. These
can be kept up to date by these apps themselves, or using `brew upgrade`.
Keeping track of the apps to install can be achieved using a Brewfile.

Homebrew does not offer the same level of declarative configuration as is
possible through Nix. At this time, I'm choosing Homebrew over Nix for apps due
to the ease of use. Nix will be used to install shell binaries, and allow me to
stay aware of the state-of-the-art of Nix for macOS apps.

See: https://github.com/NixOS/nix/issues/7055
