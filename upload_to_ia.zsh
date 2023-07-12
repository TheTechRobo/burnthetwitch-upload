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

# TODO: Date range in metadata?

echo "Assuming that you mean channel ${CHANNEL}. Also assuming that it's ok."
generated_url="https://twitch.tv/${CHANNEL}"
echo "Generated URL:\t${generated_url}"
creator="${CHANNEL}"
echo "Creator:\t${creator}"
description="#burnthetwitch grabs of the Twitch channel ${CHANNEL}. METADATA ONLY!"
echo "Desc:\t${description}"

ia upload -vc "twitchTEST3-${CHANNEL}" --metadata "title:Twitch channel ${CHANNEL}" --metadata "scraper:#burnthetwitch (on hackint)" --metadata "originalurl:${generated_url}" --metadata "creator:${creator}" --metadata "description:${description}" "${CHANNEL}"
