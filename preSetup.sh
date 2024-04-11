#!/bin/bash

# This shell script automates downloading the archive.zip online, and then sets up the file for the project.
wget -O archive.zip https://pages.stat.wisc.edu/~jwvanzeeland/archive.zip

unzip archive.zip

rm archive.zip

mkdir data

mv *202[23] data # move all the monthly directories into one file

