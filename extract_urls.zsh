#!/usr/bin/zsh

set -e

channel="${1}"

echo "NAME: ${channel}"

# For every chat.json file, run the url extratrator

(
echo Locking
flock 9 || exit 1
echo Locked
find "${channel}" -name "chat.json" -print0 | xargs -0 -n1 python3 urlex.py | sort -u >> URLS.TXT
echo Unlocking
) 9>URLS.TXT.LCK
