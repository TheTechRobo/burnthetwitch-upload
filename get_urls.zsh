#!/usr/bin/zsh

set -e

(
set -e
echo 'Waiting for lock...'
flock 9 || exit 1
echo 'Lock acquired.'
# Unifify
# Todo: Do this a better way that doesn't involve sorting
sort -u URLS.TXT > URLS.TXT_UNIQ && rm URLS.TXT && mv URLS.TXT_UNIQ URLS.TXT
# Write everything up to line 50000 to output
head -n 50000 URLS.TXT > output || exit 3
# Delete everything before line 50001
tail -n +50001 URLS.TXT > URLS.TXT_UP && rm URLS.TXT && mv URLS.TXT_UP URLS.TXT
echo 'Exiting'
) 9>URLS.TXT.LCK

