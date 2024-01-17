#!/bin/bash

USER=$1

# Create a folder called backups in the home folder if it does not exist
backup_folder="/home/$USER/backups"
mkdir -p "$backup_folder"

# Freeze all Docker containers if Docker is installed
if command -v docker &>/dev/null; then
    docker pause $(docker ps -q)
fi

# Create a folder inside backups with a timestamp
timestamp=$(date "+%Y%m%d%H%M%S")
backup_folder="$backup_folder/$timestamp"
mkdir "$backup_folder"

# Copy all folders named "docker" in the home directory using rsync
rsync -a --exclude=backups "/home/$USER/docker" "$backup_folder"

# Zip the timestamp folder
zip -r "$backup_folder.zip" "$backup_folder"

# Remove the source if the rsync and zip succeed
if [ $? -eq 0 ]; then
    rm -rf "$backup_folder"
fi

# Unfreeze all Docker containers if Docker is installed
if command -v docker &>/dev/null; then
    docker unpause $(docker ps -q)
fi

# Delete the zip file inside the backups folder if it's more than a week old
find "/home/$USER/backups" -name '*.zip' -mtime +7 -exec rm {} \;
