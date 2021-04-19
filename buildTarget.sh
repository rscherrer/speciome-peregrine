#!/bin/bash

# This script compiles the program on the Peregrine cluster

# Run this script from the cluster folder
# Pass it the path to the target folder as argument

# Make a target folder

if [ "$1" != "" ]; then

	if [ -d "$1" ]; then

		echo "Overwriting target folder..."
		rm -rf $1		

	else

		echo "Creating target folder..."	

	fi	

	mkdir $1

	echo "Building the program..."

	# Produce an executable (from here cannot be tested locally)

	module load Qt5
	qmake ./speciome/speciome.pro # assuming we are in the cluster folder
	make --silent release

	# Move the executable to the target folder

	mv speciome $1

	# Move all intermediate files generated during the build to a build folder

	if [ -d "build" ]; then

		rm -rf build

	fi

	mkdir build

	mv Makefile build
	mv Makefile.Debug build
	mv Makefile.Release build
	mv debug build
	mv release build

	# Copy the protocol and the running script to the target folder

	cp protocol.txt $1
	cp parameters.txt $1
	cp run_simulations.sh $1
	cp rerun_simulations.sh $1

	# Copy the python scripts to the target folder

	cp deploy.py $1
	cp pytilities.py $1

	echo "Done."

else

	echo "Please provide target folder"

fi
