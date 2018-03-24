#!/bin/bash

while read line
do
    echo "makeDestinationBuild/"$line".md"
    done < line.txt
