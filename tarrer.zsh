#!/usr/bin/zsh

# tarrer.sh
# AUTHOR: TheTechRobo

############################
#        TARRER.SH         #
############################
 # Walks through a BTT-     #
 #generated folder, tarring #
 # crawl dirs.              #
 #ONLY USE WITH BTT FOLDERS!#
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
    # Test if folder to walk is not provided
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

vfailed() {
    echo
    echo "While processing ${1}:"
    echo "WARC VERIFICATION FAILED."
    echo "${2}"
    echo "Refusing to continue!"
    exit 42
}

verify_warc_contents() {
    local DIRECTORY_TO_VERIFY="$1"
    if [[ ! -d "${DIRECTORY_TO_VERIFY}/warcs" ]] then
        echo "No warcs folder to verify"
        return
    fi
    # WARNING: ONLY detects warc.gz files!
    # Remove glob pattern if no matches
    for warc in ${DIRECTORY_TO_VERIFY}/warcs/*.warc.gz(N) ${DIRECTORY_TO_VERIFY}/warcs/*.warc.gz.open(N) ; do
        # Run warc-tiny on the warc.gz
        # warc-tiny returns a non-zero status code when verification fails,
        # so we need to check that.
        # We stifle the bad status code with the true command so that
        # the bad status code doesn't crash the program and we can
        # at least get an error message in.
        # Then we use the pipestatus variable to find out if both
        # zstdcat and warc-tiny were successful or not.
        zstdcat "${warc}" | warc-tiny verify - | true
        # pipestatus disappears when you read it, so we need to copy
        # it to another variable
        local pipe_status=( ${pipestatus[@]} )
        # Crash with an error message if the verification fails
        if [[ "${pipe_status[1]}" != "0" ]] then
            vfailed "${warc}" "Zstdcat output bad status code"
        elif [[ "${pipe_status[2]}" != "0" ]] then
            vfailed "${warc}" "Warc-tiny output bad status code"
        fi
        # If the filename ends with .warc.gz.open
        if [[ "${warc}" =~ "\.warc\.gz\.open$" ]] then
            # Create new filename without the `.open` at the end
            local new_name="$(echo ${warc} | sed 's/\(.*\).open/\1/')"
            # Rename the file to that filename
            mv -v "${warc}" "${new_name}"
        fi
    done
}

tar_subdirectory() {
    DIRECTORY_TO_TAR="$1"
    if [[ -e "${DIRECTORY_TO_TAR}.tar" ]] then
        # This should have been caught by the caller
        echo "fatal: Refusing to clobber existing tarfile"
        exit 9
    fi
    verify_warc_contents "${DIRECTORY_TO_TAR}"
    # Tar the files to $DIRECTORY_TO_TAR.tar
    # The W flag verifies stuff after it's written
    tar cWf "${DIRECTORY_TO_TAR}.tar" "${DIRECTORY_TO_TAR}"
    # Even though the W flag verifies stuff after it's written,
    # better safe than sorry.
    # I'm also not sure if this compares file CONTENT, so I
    # don't yet want to remove the W flag from above.
    # (We don't want a file corrupting thanks to magic bit flips.)
    # Temporarily disabled for reasons.
    echo "SKIPPING TAR VERIFICATION."
    #tar df "${DIRECTORY_TO_TAR}.tar" "${DIRECTORY_TO_TAR}"
    # It should now be safe to remove the non-tar file, as
    # we've just established that it matches the filesystem
    rm -r "${DIRECTORY_TO_TAR}"
}

tar_or_recurse() {
    local folder=$1
    local fol_basename="$(basename ${folder})"
    if [[ -z "${folder}" ]] then
        # For some reason the folder was not provided
        echo "An internal error occured"
        exit 12
    fi
    if [[ -z "${fol_basename}" ]] then
        # Basename did not return anything valid
        echo "Basename sanity check FAILED..."
        exit 15
    fi
    if [[ ! -d "${folder}" ]] then
        # Not a directory; this should have been caught by the caller
        echo "fatal: Not a directory: ${folder}"
        exit 11
    fi
    # If this is a channel grab, tar as-is.
    if [[ "${fol_basename}" =~ "^[0-9]+\\.[0-9]+$" ]] then
        tar_subdirectory "${folder}"
    # If this is a VOD folder, tar everything inside.
    elif [[ "${fol_basename}" =~ "^[0-9]+$" ]] then
        # Check file count in directory
        # If directory does not exist, ls will return nothing
        # to stdout, thus this will work nevertheless
        local dcount="`ls -1 ${folder} 2>/dev/null | wc -l`"
        if [[ dcount -eq 0 ]] then
            echo "\tSkipping empty subdirectory ${folder}"
            continue
        fi
        # Iterate over files in folder
        for subdirectory in ${folder}/* ; do
            # Assert that it's a directory
            if [[ ! -d "${subdirectory}" ]] then
                echo "\tSkipping non-directory ${subdirectory}"
                continue
            fi
            # Tar the subdirectory
            tar_subdirectory "${subdirectory}"
        done
    else
        # Invalid directory name (for these purposes)
        echo
        echo "Tf?"
        echo "${subdirectory}"
        exit 100
    fi
}

CHANNELS_DONE=0

# Iterate over all subdirectories
for subdirectory in ${CHANNEL_NAME}/*; do
    # Increase counter
    let "++CHANNELS_DONE"
    # Tarring files is useless;
    # plus, they are likely tar files from a previous run
    if [[ ! -d "${subdirectory}" ]] then
        echo "\tSkipping non-directory ${subdirectory}"
        continue
    fi
    echo "Tarring ${subdirectory} into ${subdirectory}.tar..." \
        "(${CHANNELS_DONE}/${FILE_COUNT})"
    tar_or_recurse "${subdirectory}"
done
