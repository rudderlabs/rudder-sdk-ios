#!/bin/bash

if [ $(git tag -l "$1") ]; then
    exit 0
else
    exit 1
fi
