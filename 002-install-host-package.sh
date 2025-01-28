#!/bin/bash

###
# This script sets up the Ubuntu Server Host for The
# Yocto Project. The script installs the dependencies
# needed in Ubuntu and set up the system for the Stack
###

set -ex

# Install needed packages in the host for the Yocto project
install_packages() {
    sudo apt-get update
    sudo apt-get install gawk wget git diffstat unzip texinfo gcc build-essential \
        chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils \
        iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
        python3-subunit mesa-common-dev python3-subunit zstd liblz4-tool file \
        locales libacl1 -y

    sudo apt-get install cmake u-boot-tools srecord cppcheck -y
}

# Set up the locale
set_up_locale() {
    sudo apt-get update
    sudo locale-gen en_US.UTF-8
}

main(){
    install_packages
    set_up_locale
}

main