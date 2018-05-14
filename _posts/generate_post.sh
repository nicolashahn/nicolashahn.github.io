#!/bin/bash

# Generates a blank post from the date, a title (script argument)
# Run this from /_posts directory

main() {

    DATE=`date +%Y-%m-%d`

    if [[ $# -eq 0 ]] ; then
        echo "Usage: $0 kebab-case-post-title"
        exit 1
    fi

    KEBAB_TITLE="$1"
    POST_FILE="$DATE-$KEBAB_TITLE.md" 

    # Create post file, autofill date
    cp "unpublished/template.md" "$POST_FILE"
    sed -i '' -- "s/DATE/$DATE/g" "$POST_FILE"

    echo "New post file created at: $POST_FILE"
    exit 0
}

main $@
