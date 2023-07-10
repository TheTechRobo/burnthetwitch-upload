#!/usr/bin/zsh

# tarrer.sh
# AUTHOR: TheTechRobo

############################
#        TARRER.SH         #
############################
 # Walks through a BTT-     #
 #generated folder, tarring #
 # all subdirectories.      #
  ###########################

# set -e has its pitfalls, but in reality there is no reason
# we shouldn't use it here.
set -e

# Put the CLI args into a convenient
# array so we can use it inside functions
export args=( "$@" )
# Put the name of the file into a variable
export program_name="$0"
# Put the number of CLI args into a variable
export number_of_args="$#"

get_folder_name() {
    # Test if folder to walk is empty
    if [[ -z "${args[1]}" ]] then
        echo "Usage: ${program_name} <FOLDER_TO_WALK>"
        echo "You did not provide a FOLDER_TO_WALK."
        exit 4
    fi
    # Test if number of arguments is non-1
    if [[ "${number_of_args}" -ne 1 ]] then
        echo "Usage: ${program_name} <FOLDER_TO_WALK>"
        echo "You provided an invalid number of arguments."
        echo "I found ${number_of_args} arguments."
        exit 5
    fi
    # Set CHANNEL_NAME variable to the folder to walk
    export CHANNEL_NAME="${args[1]}"
    echo "Operating on directory ${CHANNEL_NAME}."
}

# Puts the folder name into the CHANNEL_NAME directory
get_folder_name

# Ensure that there is at least one folder
# Calls ls with -1 (for one entry per line) on the directory
FILE_COUNT="$(ls -1 ${CHANNEL_NAME} 2>/dev/null | wc -l)"

if [[ "${FILE_COUNT}" -eq 0 ]] then
    echo "fatal: Directory is empty or nonexistent."
    exit 6
fi

echo "Discovered ${FILE_COUNT} items inside directory."

tar_subdirectory() {
    DIRECTORY_TO_TAR="$1"
    if [[ -e "${DIRECTORY_TO_TAR}.tar" ]] then
        echo "fatal: Refusing to clobber existing tarfile"
        exit 9
    fi
    # Tar the files to $DIRECTORY_TO_TAR.tar
    # The W flag verifies stuff after it's written
    tar cWf "${DIRECTORY_TO_TAR}.tar" "${DIRECTORY_TO_TAR}"
    # Even though the W flag verifies stuff after it's written,
    # better safe than sorry.
    # I'm also not sure if this compares file CONTENT, so I
    # don't yet want to remove the W flag from above.
    # (We don't want a file corrupting thanks to magic bit flips.)
    tar df "${DIRECTORY_TO_TAR}.tar" "${DIRECTORY_TO_TAR}"
    # It should now be safe to remove the non-tar file, as
    # we've just established that it matches the filesystem
    rm -r "${DIRECTORY_TO_TAR}"
}

output_progress_bar() {
    printf '=%.0s' $(seq 1 "${CHANNELS_DONE}") | tqdm --total "${FILE_COUNT}" \
        > /dev/null
}

CHANNELS_DONE=1

# Iterate over all subdirectories
for subdirectory in ${CHANNEL_NAME}/*; do
    # Tarring files is useless;
    # plus, they are likely tar
    # files from a previous run
    if [[ ! -d "${subdirectory}" ]] then
        echo "\tSkipping non-directory ${subdirectory}"
        continue
    fi
    echo "Tarring ${subdirectory} into ${subdirectory}.tar..." \
        "(${CHANNELS_DONE}/${FILE_COUNT})"
    tar_subdirectory "${subdirectory}"
    let "++CHANNELS_DONE"
done
