#!/bin/bash

# @see https://dev.to/slobodan4nista/automating-text-extraction-from-screenshots-with-tesseract-and-gnome-screenshot-maj

# Create a temporary directory
TMPDIR=$(mktemp -d)

# Take a screenshot of a selected area and save it as screenshot.png in the temporary directory
gnome-screenshot -a -f $TMPDIR/screenshot.png

# Process the screenshot with Tesseract and save the result to a text file in the temporary directory
tesseract $TMPDIR/screenshot.png $TMPDIR/output

# Copy the result to the clipboard
# ignore all non-ASCII characters
cat $TMPDIR/output.txt |
    tr -cd '\11\12\15\40-\176' | grep . | perl -pe 'chomp if eof' |
    xclip -selection clipboard

# Optionally, remove the temporary directory when done
rm -r $TMPDIR
