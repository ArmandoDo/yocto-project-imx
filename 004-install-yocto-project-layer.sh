#!/bin/bash

###
# This script sets up and installs the config for
# the Yocto Project layer
###

set -ex

main() {
    # Create new folder
    mkdir iwg61m-release-bsp && cd iwg61m-release-bsp
    # Init and sync the repo
    repo init -u https://git-codecommit.ap-south-1.amazonaws.com/v1/repos/iwave-imx9-manifest \
        -b iwave-linux-scarthgap -m iwg61m_smarc_6.6.36_2.1.0_0.1.xml
    repo sync
}

main