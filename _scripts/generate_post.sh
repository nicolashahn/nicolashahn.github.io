#!/bin/bash

# Generates a blank post from the date, a title (script argument)
# NOTE: Run from repo root directory

main () {

    if [[ $# -eq 0 ]] ; then
        echo "Usage: $0 <post-title-in-kebab-case>"
        exit 0
    fi

    touch "_posts/`date +%Y-%m-%d`-$1.md" 
}

main
