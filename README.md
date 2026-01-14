# OpenCode-Container

Containerfile and launch script for running OpenCode sandboxed in podman.

Installation:

```sh
ln -sf "$(readlink -f ./opencode-container.sh)" ~/.local/bin/opencode
```

This script will:

1. Build the image with podman if necessary
2. Detect the git repository in the current worktree
3. Launch a containerized OpenCode with only that repo (or $PWD) bind-mounted
   as volume

If `.jj` exists in the repo root, that will be mounted read-only to prevent
accidental destruction with `git clean`

Instead of the real $HOME, OpenCode will see only a bare minimum of
subdirectories, which are redirected into `./sandbox_home/`. If you want to
retain your current configuration, move or copy it there.
