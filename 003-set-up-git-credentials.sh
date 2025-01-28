#!/bin/bash

###
# This script sets up the config of git for the 
# Yocto Project.
###


set -ex

# Set up git global config and iwave credentials
git config --global user.name ${GIT_USERNAME}
git config --global user.email ${GIT_EMAIL}
git config --global credential.helper 'store --file ~/.iwave-credentials'
cat <<EOF | xargs | sed 's/ //g' | tee ~/.iwave-credentials
https://iwave-at-
518522664578:S0ppFM%2ftJqihb3CuCATteqz%2f8oQ0HiVnl%2b%2b3wLGOZsg%3d@git-
codecommit.ap-south-1.amazonaws.com
EOF