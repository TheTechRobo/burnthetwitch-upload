#!/usr/bin/zsh

set -e

channel="${1}"

echo "NAME: ${channel}"

# For every chat.json file, run the url extratrator

(
set -e
echo Locking
flock 9 || exit 1
echo Locked
find "${channel}" -name "chat.json" -print0 | xargs -0 -r -n1 python3 urlex.py | sort -u >> URLS.TXT
ps=$pipestatus
echo $ps
if [[ "${ps[0]}" -ne 0 ]] then
    echo "Ps0 returned 1"
    exit 9
elif [[ "${ps[1]}" -ne 0 ]] then
    echo "Ps1 returned 1"
    exit 10
elif [[ "${ps[2]}" -ne 0 ]] then
    echo "Ps2 returned 1"
    exit 11
fi
echo Unlocking
) 9>URLS.TXT.LCK
