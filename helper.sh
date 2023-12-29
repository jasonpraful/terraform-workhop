#!/bin/bash

if [ -z "$1" ]; then
    echo "Program requires at least one operation. Use 'clean' or 'uncomment' or 'comment' or 'osa' as first parameter."
    exit 1
fi

operation="$1"

if [ "$operation" == "clean" ];
then
    if [ -z "$2" ]; then
        echo "Program requires second parameter to be a directory."
        exit 1
    fi
    directory="$2"
    if [ ! -d "$directory" ]; then
        echo "Directory '$directory' does not exist."
        exit 1
    fi
    cd "$directory"
    # Remove terraform files
    rm -rf .terraform .terraform.lock.hcl .terraformrc terraform.tfstate terraform.tfstate.backup
    if [ -d "terraform" ]; then
        cd terraform
        rm -rf .terraform .terraform.lock.hcl .terraformrc terraform.tfstate terraform.tfstate.backup
        cd ..
    fi

    tree -a .
    exit 0
elif [ "$operation" == "uncomment" ] || [ "$operation" == "comment" ];
then
    if [ -z "$2" ]; then
        echo "Program requires second parameter to be a file."
        exit 1
    fi
    if [ -z "$3" ]; then
        echo "Program requires third parameter to be a line number."
        exit 1
    fi
    if [ -z "$4" ]; then
        echo "Program requires fourth parameter to be a line number."
        exit 1
    fi
    file="$2"
    if [ ! -f "$file" ]; then
        echo "File '$file' does not exist."
        exit 1
    fi
    line_from="$3"
    line_to="$4"
    if [ "$line_from" -gt "$line_to" ]; then
        echo "Line from '$line_from' is greater than line to '$line_to'."
        exit 1
    fi
    if [ "$operation" == "comment" ]; then
        
        find "$file" -type f -exec sed -i '' -e "$line_from,$line_to s/^/# /" {} \;
    else
        find "$file" -type f -exec sed -i '' -e "$line_from,$line_to s/^# //" {} \;
    fi
    exit 0
elif [ "$operation" == "osa" ];
then
    if [ -z "$2" ]; then
        echo "Program requires second parameter to be a directory."
        exit 1
    fi
    if [ -z "$3" ]; then
        echo "Program requires third parameter to be a command."
        exit 1
    fi
    current_dir=$(pwd)
    osascript <<EOD
    tell application "iTerm2"
    set newWindow to (create window with default profile)
    tell current session of newWindow
        delay 2
        write text "cd $current_dir/$2"
        write text "$3"
    end tell
    end tell
EOD
    exit 0
else
    echo "Unknown operation '$operation'."
    exit 1
fi
