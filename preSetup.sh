#!/bin/bash

# Please make sure you have downloaded the file from the website stated.
unzip archive.zip

rm archive.zip

mkdir -p data

mv *202[23] data # move all the monthly directories into one file

