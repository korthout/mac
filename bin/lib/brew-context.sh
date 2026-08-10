CONTEXT_FILE="$XDG_CONFIG_HOME/homebrew/context"
if [ ! -f "$CONTEXT_FILE" ]; then
	echo "No context set for this machine. Run: echo work|personal > $CONTEXT_FILE" >&2
	exit 1
fi

CONTEXT=""
read -r CONTEXT < "$CONTEXT_FILE" || true
case "$CONTEXT" in
	work) OTHER_CONTEXT=personal ;;
	personal) OTHER_CONTEXT=work ;;
	*)
		echo "Invalid context '$CONTEXT' in $CONTEXT_FILE (expected 'work' or 'personal')" >&2
		exit 1
		;;
esac

BREWFILE="$XDG_CONFIG_HOME/homebrew/Brewfile.$CONTEXT"
# shellcheck disable=SC2034 # consumed by bin/brew-install and bin/brew-uninstall, not within this file
OTHER_BREWFILE="$XDG_CONFIG_HOME/homebrew/Brewfile.$OTHER_CONTEXT"
export HOMEBREW_BUNDLE_FILE="$BREWFILE"

# Case-insensitive, default-aware yes/no prompt. Bash-3.2-safe (no ${var,,}).
# Usage: prompt "Share this? [y/N]"       (default: no)
#        prompt "Continue? [Y/n]" y       (default: yes)
function prompt() {
	local msg=$1 default=${2:-n} ans
	read -r -p "$msg " ans
	ans=${ans:-$default}
	case "$ans" in
		[Yy]|[Yy][Ee][Ss]) return 0 ;;
		*) return 1 ;;
	esac
}

# Resolves a package name — plus, separately, whether --cask/--casks was
# passed — to the tap-qualified name that `brew bundle add`/`remove` write
# into and match against a Brewfile: .full_name for formulae, .full_token
# for casks.
#
# .full_token, not .token: `brew bundle list --cask` prints the *short*
# token, but a Brewfile line for a tapped cask carries the full one. Using
# .token meant `bundle remove` silently no-opped (exit 0, line untouched)
# and `bundle add` appended a second, differently-tapped entry. Because
# `bundle list` can't see a full_token, in_bundle() below matches the
# Brewfile text directly instead of shelling out to `bundle list`.
#
# This makes resolution and matching agree on whatever name you pass; it
# does not disambiguate a bare one. `--cask orca` still resolves to
# homebrew/cask/orca, never stablyai/orca/orca — pass the tap-qualified
# name for a tapped package. What's fixed is that the two are now told
# apart rather than conflated under the shared short token `orca`.
#
# Deliberately does NOT forward "$@" verbatim to `brew info`: install-only
# flags (--HEAD, --force, --build-from-source, ...) are valid for `brew
# install` but not for `brew info`, which would exit 1 on them — after the
# package is already installed. require_single_package() already rejects
# any flag it can't record faithfully, so by the time resolve_package runs,
# the only flag left to consider is --cask/--casks.
# Prints: "formula <full-name>" or "cask <token>"
function extract_package_name() {
	local name arg
	for arg in "$@"; do
		case "$arg" in
			-*) ;;
			*) name=$arg ;;
		esac
	done
	echo "$name"
}

function is_cask() {
	local arg
	for arg in "$@"; do
		case "$arg" in
			--cask|--casks) return 0 ;;
		esac
	done
	return 1
}

function resolve_package() {
	local name info
	name=$(extract_package_name "$@")
	if is_cask "$@"; then
		info=$(brew info --json=v2 --cask "$name") || return 1
	else
		info=$(brew info --json=v2 "$name") || return 1
	fi
	if [ "$(jq '.formulae | length' <<<"$info")" -gt 0 ]; then
		echo "formula $(jq -r '.formulae[0].full_name' <<<"$info")"
	else
		echo "cask $(jq -r '.casks[0].full_token' <<<"$info")"
	fi
}

# Matches the Brewfile text rather than `brew bundle list`, which prints
# short cask tokens and so can't see the full_token resolve_package emits.
#
# Not -x: `brew "atuin", restart_service: :changed` is a legitimate entry,
# so the match must be a prefix, not the whole line. The trailing quote in
# the needle is what keeps it from being a loose substring match — `brew
# "jq"` matches neither `brew "jq-extra"` nor `brew "foo/bar/jq"`.
#
# A missing or unreadable file makes grep exit non-zero, i.e. reads as "not
# present" — the same fail-closed behaviour the `bundle list` version had.
# Usage: in_bundle formula|cask <name> <brewfile-path>
function in_bundle() {
	local type=$1 name=$2 file=$3 prefix
	case "$type" in
		formula) prefix=brew ;;
		cask) prefix=cask ;;
		*) return 1 ;;
	esac
	grep -qF -- "$prefix \"$name\"" "$file" 2>/dev/null
}

# Guardrail: this tool supports exactly one package per invocation, optionally
# preceded by --cask/--casks/--formula/--formulae. "$@" exists for that one
# disambiguating flag, not for batches — without the count check, a
# multi-package call (human typo, or an agent assuming brew-install works
# like `brew install pkg1 pkg2`) would silently mis-track: brew/bundle would
# act on all of them, but resolve_package only ever reads the first, so the
# share decision and commit message would reflect one package while the
# shell state reflects several.
#
# Any other flag is rejected outright, for the same reason: flags like
# --HEAD or --force change what gets installed but can't be represented in
# a Brewfile line, so recording the package without them would silently
# mis-record what's actually on disk.
# Usage: require_single_package "$@"
function require_single_package() {
	local count=0 arg
	for arg in "$@"; do
		case "$arg" in
			--cask|--casks|--formula|--formulae) ;;
			-*)
				echo "Unsupported flag '$arg' — this tool only accepts --cask/--formula, because other flags can't be recorded in the Brewfile." >&2
				exit 1
				;;
			*) count=$((count + 1)) ;;
		esac
	done
	if [ "$count" -ne 1 ]; then
		echo "This tool supports exactly one package at a time (optionally preceded by a flag like --cask)." >&2
		exit 1
	fi
}

# Commits and pushes only if something is actually staged, so re-running
# these tools on a package that's already fully installed and synced is a
# quiet no-op instead of a "nothing to commit" failure under set -e.
#
# A rejected push (remote moved on — increasingly likely now that the share
# flow writes into the *other* context's file from this machine) is not
# auto-retried: `config pull --rebase` would refuse to start on a dotfiles
# work-tree that normally has unrelated tracked modifications sitting
# around, and a failed rebase leaves $HOME mid-rebase with conflict markers
# — worse than today's failure mode of "one unpushed local commit." So on
# rejection this just names the exact recovery command and exits.
# Usage: commit_and_push "<message>" <path> [<path> ...]
function commit_and_push() {
	local message=$1
	shift
	config add "$@"
	if ! config diff --cached --quiet; then
		config commit -m "$message"
		config push || {
			echo "Push rejected. Recover with: config pull && config push" >&2
			exit 1
		}
	else
		echo "Nothing changed — skipping commit."
	fi
}
