#!/usr/bin/env bash
#
# Test out dev build on Fedora.
#
# Usage:
#   test/fedora.sh <function name>

# TODO: We need to mount the Oils repo in here
# https://gomix.github.io/foss_topics/containers/podman/running_fedora_with_podman.html
interactive() {
  sudo podman run -i -t --name fedora fedora
}

"$@"
