#!/bin/bash

###
# This script sets up the repo utility. Repo is a tool built
# on top of Git that makes it easier to manage projects that
# contain multiple repositories, which do not need to be on
# the same server.
###

set -ex

main() {
    # Create new bin folder
    mkdir ~/bin
    # Download script and set up the permissions
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
    # Export PATH variable
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
}

main