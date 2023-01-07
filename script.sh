#!/bin/bash

# stop on errors
set -e

# match any image written in markdown format
PATTERN="!\[.*\]\(https?[^]]+\.(png|gif|jpe?g|bmp|svg|tiff)\)"

echo "Checking if any md file needs to download images..."

# get the files (markdown files) that have markdown images
FILES=$(LC_ALL=C grep -r -s -i -l --include \*.md -E "$PATTERN" .)

echo "$FILES" | while read -r FILE ; do

    TRDLINE=$(sed -n '3p' "$FILE")
    FLDRNAME=$(echo "${TRDLINE:5}" | sed 's/ //g')
    FILE_DIRECTORY=$FLDRNAME

    # Get the images markdown URLs
    URLS=$(grep -o -i -E "$PATTERN" "$FILE")

    # go to next file if no image urls were found
    [ -z "$URLS" ] && continue

    # create images folder if it's not here already
    [ ! -d "out/$FILE_DIRECTORY/images" ] && mkdir -p "out/$FILE_DIRECTORY/images"

    echo "Downloading images for $FILE..."

    echo "$URLS" | while read -r url ; do

        CORRECT_URL=$(echo -e ${url##*]} | tr -d '()')
        START_OF_CORRECT_URL="${CORRECT_URL%/*}"
        FILE_NAME=${CORRECT_URL##*/}

        # download images to the "images" folder
        [ ! -f "out/$FILE_DIRECTORY/images/$FILE_NAME" ] && wget "$CORRECT_URL" -P "out/$FILE_DIRECTORY/images/" -q

        # replace URL by the local path in the markdown file
        # macOS needs a blank -i argument
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' -e "s|$START_OF_CORRECT_URL|images|g" "$FILE" > "out/$FILE_DIRECTORY/index.md"
        else
            sed -e "s|$START_OF_CORRECT_URL|images|g" "$FILE" > "out/$FILE_DIRECTORY/index.md"
        fi

    done

done
