#!/bin/bash -e

readonly image=opencode:latest

workdir="$(readlink -f "$PWD")"
readonly workdir
cd -P -- "$(dirname "$(readlink -f "$0")")"

readonly sandbox_home="$PWD/sandbox_home"

if [[ -t 2 ]]; then
  BOLD=$'\x1b[1m'
  RED=$'\x1b[31m'
  BLUE=$'\x1b[34m'
  RESET=$'\x1b[0m'
else
  BOLD=''
  RED=''
  BLUE=''
  RESET=''
fi

die() {
  # shellcheck disable=SC2059
  printf "$BOLD$RED  ==> ERROR: $RESET$BOLD$1$RESET\n" "${@:2}" >&2
  exit 1
}

msg() {
  # shellcheck disable=SC2059
  printf "$BOLD$BLUE:: $RESET$BOLD$1$RESET\n" "${@:2}"
}

envvars=("-eHOME=$HOME")
mkdir -p "$sandbox_home"/{.bun,.cache,.config,.local}
volumes=(
  "-v$sandbox_home/.bun:$HOME/.bun"
  "-v$sandbox_home/.cache:$HOME/.cache"
  "-v$sandbox_home/.config:$HOME/.config"
  "-v$sandbox_home/.local:$HOME/.local"
)

gittree="$(git rev-parse --show-toplevel 2>/dev/null || :)"
if [[ -n "$gitrepo" ]]; then
  volumes+=("-v$gittree:$gittree")
else
  volumes+=("-v$workdir:$workdir")
fi
if [[ -n "$GIT_DIR" ]]; then
  gitdir_abs="$(realpath "$GIT_DIR")"
  envvars+=("-eGIT_DIR=$gitdir_abs")
  volumes+=("-v$gitdir_abs:$gitdir_abs")
fi

if [[ -d "$gittree/.jj" ]]; then
  volumes+=("-v$gittree/.jj:$gittree/.jj:ro")
fi

if ! podman image exists "$image" 2>/dev/null; then
  msg 'Building image "%s" in %s' "$image" "$PWD"
  podman build -t "$image" "$PWD"
  msg 'Image "%s" built successfully' "$image"
fi

exec podman run --rm -it \
  --userns keep-id \
  --detach-keys "" \
  --cap-drop ALL \
  --read-only \
  --security-opt no-new-privileges \
  "${volumes[@]}" \
  "${envvars[@]}" \
  -w "$workdir" \
  "$image" \
  "$@"
