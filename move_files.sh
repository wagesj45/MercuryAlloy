#!/bin/bash

# Check for the required number of parameters
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <MILESTONE_VERSION> <EXE_FILE>"
    exit 1
fi

# Assign the parameters to meaningful variable names
MILESTONE_VERSION="$1"
EXE_FILE="$2"

# Print the parameters to verify they're passed correctly
echo "Milestone Version: $MILESTONE_VERSION"
echo "Executable: $EXE_FILE"

# Insert the file moving logic here. For example:
# mv "$EXE_FILE" "/desired/path/$MILESTONE_VERSION/"

