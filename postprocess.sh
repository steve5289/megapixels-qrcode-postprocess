#!/bin/bash
## Script Description
# This script's purpose is to act as a postprocessing script as part of megapixe's image processing by detecting, and performing actions based on them (with user input).


CLEAN_DNG_FILE=1
STOCK_POSTPROCESS_PATH="/usr/share/megapixels/postprocess.sh"


## 
# Execution Starts here
function main {
    local BURST_DIR="$1"
    local IMAGE_NAME="$2"
    local DNG_FILE="$2.dng"
    local IMAGE_FILE

    run_stock_postprocess "$@"

    exec > ~/.config/megapixels/postprocess.log 2>&1
    get_image_file "$IMAGE_NAME"
    if [[ -n "$OUTPUT" ]]; then
        IMAGE_FILE="$OUTPUT"
        if [[ "$CLEAN_DNG_FILE" -eq 1 ]]; then
            rm -f "$DNG_FILE"
        fi
    else
        die "Error! Could not find image file with name '$IMAGE_NAME'!"
    fi

    qr_code "$IMAGE_FILE"
}

##
# As we are only given a image name (no extention like .jpg) we need to figure out what that is.
function get_image_file {
    local IMAGE_NAME="$1"
    local file

    for file in "$IMAGE_NAME."{jpg,tiff,png}; do
        if [[ -e "$file" ]]; then
            OUTPUT="$file"
            return
        fi
    done
}

##
# Run the normal mexgapixels postprocess script so that we don't need to maintain a version of that.
function run_stock_postprocess {
    $STOCK_POSTPROCESS_PATH "$@" || exit $?
}

##
# Process the image for a qr code
function qr_code {
    local IMAGE_FILE="$1"
    local QR_CODE
    
    qr_code_check_deps || die "Error dependancies not met for qr code scanning"

    QR_CODE=$(zbarimg -q --raw "$IMAGE_FILE")

    # If no qr code found, then just exit
    if [[ -z "$QR_CODE" ]]; then
        #echo "QR Code not found... exiting"
        exit 0
    fi

    qr_code_launch "$QR_CODE"
    rm -f "$IMAGE_FILE" 
    
}

##
# Ensure the needed dependancies are installed to run this.
function qr_code_check_deps {
    command -v zbarimg > /dev/null 2>&1 || return 1
    command -v zenity > /dev/null 2>&1 || return 1
    return 0
}

##
# Depending on the type of qr code perform different actions. Always ask the user before doing anything.
function qr_code_launch {
    local QR_CODE="$1"
    local SPLIT PREFIX DATA RAW

    IFS=$':'
    SPLIT=( $QR_CODE )
    IFS=$' \t\n'
    PREFIX="${SPLIT[0],,}"
    DATA=$(echo "$QR_CODE" | sed -e '0,/^[a-Z]*:/s///' | sed '0,/^\/\//s///')

    case $PREFIX in
        # EMAIL
        mailto)
            prompt_yn "This image contains a qr code to send an email to '$DATA'. Would you like to send an email to them?" || exit 0

            xdg-open "$QR_CODE"
        ;;

        # CONTACT INFO
        mecard)
            prompt_yn "This image contains a qr code for contact information for someone. See text information?" || exit 0

            new_tempfile "contact" ".txt"
            TMPFILE="$OUTPUT"
            echo "$DATA" | sed 's/;/\n/g' > "$TMPFILE"
            xdg-open "$TMPFILE"
        ;;

        # GEO LOCATION
        geo)
            prompt_yn "This image contains a qr code for geo location. Open in map?" || exit 0
            xdg-open "$QR_CODE"
        ;;

        # TELEPHONE NUMBER
        tel)
            prompt_yn "This image contains a qr code for the telephone numer '$DATA'. Would you like to call it?" || exit 0
            xdg-open "$QR_CODE"
        ;;

        # SMS NUMBER
        smsto)
            IFS=$':'
            RAW=( $DATA )
            IFS=$' \t\n'

            local TEL="${RAW[0]}"
            local MESS=$(echo "$DATA" | sed '0,/^[0-9]*:/s///')

            prompt_yn "This image contains a qr code that wants you to send a sms message to a number. Would you like to see it?" || exit 0
            new_tempfile "smsinfo" ".txt"
            TMPFILE="$OUTPUT"
            echo -e "Phone Number: $TEL\nMessage to send to it: '$MESS'" > "$TMPFILE"
            xdg-open "$TMPFILE"
        ;;

        # URL
        http|https)
            prompt_yn "This image contains the URL '$QR_CODE'. Would you like to open this in the web broswer?" || exit 0
            xdg-open "$QR_CODE"
        ;;

        # Anything else
        *)
            prompt_yn "This image contains unknown information. Would you like to see the raw text?" || exit 0

            new_tempfile "qrcode" ".txt"
            TMPFILE="$OUTPUT"
            echo "$QR_CODE" > "$TMPFILE"
            xdg-open "$TMPFILE"
        ;;
    esac

}

##
# Provides a generic yes/no gui prompt. Returns 0 if yes and 1 if no
function prompt_yn {
    zenity --question --text="$@"
    return $?
}

##
# Make a temporary file
function new_tempfile {
    local NAME="$1"
    local EXT="$2"
    OUTPUT=$(mktemp "/tmp/$NAME-XXXXX") || die "Failed to create tmp file"
}

##
# exit with the given message
function die {
    echo "$@" 1>&2
    exit 2
}

main "$@"

