#!/usr/bin/zsh

set -e

# Verifies that there is only one subdirectory

d="$(ls -1 ${1} | wc -l)"

if [[ "${d}" -ne 1 ]] then
    exit 4
fi

exit 0
