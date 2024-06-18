#!/bin/bash

# Function to convert seconds to HH:MM:SS format
format_time() {
	local seconds="$1"
	local hours=$((seconds / 3600))
	local minutes=$(( (seconds % 3600) / 60 ))
	local seconds=$(( seconds % 60 ))
	printf "%02d:%02d:%02d\n" "$hours" "$minutes" "$seconds"
}

script_interval=10800 # 3 hours

# Load from .env file if it exists.
if [ -f ".env" ]; then
    source ".env"
fi

# Your repository and branch settings
HG_SRC_DIR="${HG_SRC_DIR:-$HOME/mozilla-unified}"
MERCURY_SRC_DIR="${MERCURY_SRC_DIR:-$HOME/Mercury}"
ALLOY_DIR=$(cd "$(dirname "$0")" && pwd) #Directory the current script is running from.
BUILD_OUTPUT_DIR="$HG_SRC_DIR/obj-x86_64-pc-mingw32/dist/install/sea"

echo "Mozilla Source Directory: $HG_SRC_DIR"
echo "Mercury Source Directory: $MERCURY_SRC_DIR"
echo "MercuryAlloy Directory: $ALLOY_DIR"

for i in {10..1}; do
  echo -ne "Continuing in $i\033[0K\r"
  sleep 1
done
echo -ne "Done\033[0K\r"
echo # Move to a new line at the end

# Make sure we're starting with a fresh Mercury installation.

cd $MERCURY_SRC_DIR
echo "Resetting Mercury source"
git reset --hard
git clean -fd
git fetch origin
git pull

# Copy custom files into Mercury repository to support automation/interactionless execution.

echo "Moving MercuryAlloy override files"
cp $ALLOY_DIR/MercuryOverrides/build.sh $MERCURY_SRC_DIR/build.sh
cp $ALLOY_DIR/MercuryOverrides/trunk.sh $MERCURY_SRC_DIR/trunk.sh
cp $ALLOY_DIR/MercuryOverrides/mozconfig-win-avx2-cross $MERCURY_SRC_DIR/mozconfigs/mozconfig-win-avx2-cross
#cp $ALLOY_DIR/MercuryOverrides/moz.configure $MERCURY_SRC_DIR/toolkit/moz.configure
#cp $ALLOY_DIR/MercuryOverrides/toolchain.configure $MERCURY_SRC_DIR/build/moz.configure/toolchain.configure
#cp $ALLOY_DIR/MercuryOverrides/moz.build $MERCURY_SRC_DIR/moz.build

while true; do

	# Start measuring time
	start_time=$(date +%s)

	# Determine if there are updates.

	# Existing build file
	EXE_VERSION=$(cat $ALLOY_DIR/last_built_version.txt)

	echo "Existing build file: $EXE_FILE"
	echo "Last build version: $EXE_VERSION"

	# Get Mercury updated and mozilla source up to date.
	cd $MERCURY_SRC_DIR

	#echo "Updating Mercury sourcecode"
	git stash push -m "auto-stash"
	git reset --hard
	git clean -fd
	git fetch origin
	git pull
	git stash pop

	echo "Rebasing Mozilla sourcecode"
	echo "Running trunk.sh"
	./trunk.sh

	# Extract version number from milestone.txt
	MILESTONE_VERSION=$(cat $HG_SRC_DIR/config/milestone.txt | grep '^[^#]')

	echo "Current milestone version: $MILESTONE_VERSION"

	# Compare the local and remote revisions
	if [ "$MILESTONE_VERSION" != "$EXE_VERSION" ]; then
		echo "Version mismatch. Milestone version is $MILESTONE_VERSION, but built version is $EXE_VERSION. Building."

		# Build Mercury
		echo "Running setup.sh" &&
		./setup.sh --cross-avx2 &&
		#echo "Running build.sh" &&
		./build.sh &&
		echo "Running package.sh" &&
		./package.sh

		# Get the output of the build.
		EXE_FILE=$(ls $BUILD_OUTPUT_DIR/*.exe)
		
		cd $ALLOY_DIR

		# Move the .exe file
		if [ -n "$EXE_FILE" ]; then
			echo "$MILESTONE_VERSION" > $ALLOY_DIR/last_built_version.txt
			./move_files.sh "$MILESTONE_VERSION" "$EXE_FILE"
			if [ $? -eq 0 ]; then 
				echo "Upload successful."
				./alert.sh "$MILESTONE_VERSION" "$EXE_FILE"
			else
				echo "Upload failed."
			fi
		else
			echo "No .exe file found to upload."
		fi

	else
		echo "Version $EXE_VERSION is up to date."
	fi


	# End measuring time
	end_time=$(date +%s)

	# Calculate elapsed time
	elapsed_time=$((end_time - start_time))

	# Convert elapsed time to HH:MM:SS format
	formatted_time=$(format_time $elapsed_time)

	# Display elapsed time
	echo "Script execution time: $formatted_time"

	# Prompt to press enter to close
	# read -n 1 -s -r -p "Press any key to close..."
	
	sleep $script_interval

done
