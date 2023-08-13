#!/usr/bin/zsh
# Untars a file

set -e

if [[ -z "${1}" ]] then
    echo you forgor to add the file
    exit 5
fi

if [[ ! -f "${1}/data.tgz" ]] then
    echo "file is equivalent to a doctor's handwriting"
    exit 4
fi

tar -C "${1}" -xzf "${1}/data.tgz"
rm "${1}/data.tgz"
