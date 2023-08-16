#!/usr/bin/zsh

# upload_to_ia

# Uploads a #burnthetwitch folder to IA
#
# N.B.: The directory you provide will be assumed to be the channel name.
# So an directory titled 'summoningsalt' will upload to IA as the ident
# twitch-summoningsalt
# Make sure that your directory names are all correct before using this!

# DEPENDENCIES:
#   - internetarchive Python library

set -e

THE_PATH="${1}"
CHANNEL="$(basename ${1})"
if [[ ! -z "${2}" ]] then
    CHANNEL="${2}"
fi

if [[ -z "${THE_PATH}" ]] || [[ -z "${CHANNEL}" ]] then
    echo "No channel provided. You should provide the channel dir as"
    echo "argv[1]. Make sure that it is equal to the channel username"
    echo "as the script will assume that that is the case!"
    exit 2
fi

# enter the directory right before the directory we want to archive
cd ${THE_PATH}/..
# now basename it
THE_PATH="${CHANNEL}"

# TODO: Date range in metadata?

echo "Assuming that you mean channel ${CHANNEL}. Also assuming that it's ok."
generated_url="https://twitch.tv/${CHANNEL}"
echo "Generated URL:\t${generated_url}"
creator="${CHANNEL}"
echo "Creator:\t${creator}"
description="#burnthetwitch grabs of the Twitch channel ${CHANNEL}. Includes title, thumbnail, metadata, and chat replay for each grabbed video, plus WARCs generated while discovering VODs from the channel."
echo "Description:\t${description}"

ia upload --delete -vc "twitch-metadata-${CHANNEL}" --metadata "title:Twitch channel ${CHANNEL}" --metadata "scraper:#burnthetwitch (on hackint)" --metadata "originalurl:${generated_url}" --metadata "creator:${creator}" --metadata "description:${description}" --metadata "collection:archiveteam_twitch_metadata" --retries 10 "${THE_PATH}"

# Delete all directories;
# --delete leaves empty folders behind
echo ${THE_PATH}
# the (N) will ignore the glob if no matches are found; required for channel
# items
rmdir ${THE_PATH}/**/*(N) ${THE_PATH}
