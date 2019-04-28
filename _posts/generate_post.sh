#!/bin/bash

# Generates a blank post from the date, a title (script argument)

main() {

    DATE=`date +%Y-%m-%d`

    if [[ $# -eq 0 ]] ; then
        echo "Usage: $0 kebab-case-post-title"
        exit 1
    fi

    KEBAB_TITLE="$1"
    POST_FILE="$DATE-$KEBAB_TITLE.md" 
    UNPUBLISHED="_posts/unpublished"

    # Create post file, autofill date
    cp "$UNPUBLISHED/template.md" "$UNPUBLISHED/$POST_FILE"
    sed -i  "s/DATE/$DATE/g" "$UNPUBLISHED/$POST_FILE"

    echo "$UNPUBLISHED/$POST_FILE"
    exit 0
}

main $@
