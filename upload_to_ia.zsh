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

CHANNEL="$1"

if [[ -z $CHANNEL ]] then
    echo "No channel provided. You should provide the channel dir as"
    echo "argv[1]. Make sure that it is equal to the channel username"
    echo "as the script will assume that that is the case!"
    exit 2
fi

ia upload -vc "twitchTEST-${CHANNEL}" --metadata "title:Twitch channel ${CHANNEL}" --metadata "scraper:#burnthetwitch (on hackint)" "${CHANNEL}"
