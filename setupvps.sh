#!/bin/bash

#
# Script to install Docker, Git, Git LFS, generate SSH keys and create your 
# project folder in your virtual private server (VPS)
#
# The latest version of this script is available at:
# https://github.com/geraldonovais/setupvps/blob/main/setupvps.sh
#
# Copyright (C) 2024 Geraldo Novais Jr <geraldo.novais@gmail.com>
#
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
# Unported License: http://creativecommons.org/licenses/by-sa/3.0/
#
# Attribution required: please include my name in any derivative and let me
# know how you have improved it!

# =====================================================

# Define your own values for these variables

# REPO_NAME_ON_GITHUB
# This variable will be used to:
# create the project folder with the same name in /var/www/
# Init a empty Git repo in your project folder
# Setup git FLS in your project folder

REPO_NAME_ON_GITHUB=''

# USER_NAME
# Must be the same user you have created when you did "export USER_NAME=<user_name>"
# This variable will be used to:
# Create your ssh keys and put in your home directory
# Add your user name to docker group
# Add your user as owner of the "/var/www/" folder

USER_NAME=''

# Function to check if variables are defined
check_variables() {
    if [ -z "$REPO_NAME_ON_GITHUB" ] || [ -z "$USER_NAME" ]; then
        echo "Error: REPO_NAME_ON_GITHUB or USER_NAME is not defined."
        exit 1
    fi
}

create_ssh_keys() {

    # Set the path to your public key file
    public_key_file="/home/$USER_NAME/.ssh/id_rsa.pub"

    # Check if SSH keys exist
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "SSH key pair not found. Generating SSH keys..."
        ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

        echo "copying ssh keys to authorized_keys"
        cat "$public_key_file" >> ~/.ssh/authorized_keys
        chmod 644 ~/.ssh/authorized_keys

        echo "SSH keys generated successfully."
    else
        echo "SSH key pair already exists."

        # Check if the public key is already present in authorized_keys
        if grep -qF "$(cat "$public_key_file")" ~/.ssh/authorized_keys; then
            echo "Public key already exists in authorized_keys."
        else
            # Append the public key to authorized_keys
            cat "$public_key_file" >> ~/.ssh/authorized_keys
            echo "Public key appended to authorized_keys."
        fi
    fi
}

add_know_hosts() {
    
    echo "Adding github.com to ~/.ssh/known_hosts" 
    ssh-keyscan -H -t rsa github.com >> ~/.ssh/known_hosts
}

update_system() {

    echo "Updating packages list..."

    #  Updates the list of available packages and their versions, 
    # but does not install or upgrade any packages
    sudo apt-get update -y

    # Upgrades all installed packages to their latest versions. 
    # The -y flag automatically answers "yes" to any prompts
    sudo apt-get upgrade -y

    # Clean up obsolete packages
    sudo apt-get autoremove -y
}

install_docker() {

    echo "Installing docker..."

    # Remove old versions
    sudo apt update remove -y docker docker-engine docker.io containerd runc

    # Install a few prerequisite packages which let apt use packages over HTTPS
    sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

    # Then add the GPG key for the official Docker repository to your system
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add the Docker repository to APT sources
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update your existing list of packages again for the addition to be recognized
    sudo apt update -y

    # Make sure you are about to install from the Docker repo instead of the default Ubuntu repo
    sudo apt-cache policy docker-ce

    # Finally, install Docker
    sudo apt install -y docker-ce
}

install_docker_compose() {
    sudo apt install -y docker-compose
}

add_user_to_docker_group() {

    echo "Adding user to docker group..."

    # To avoid typing sudo whenever you run the docker command,
    # we need to add your username to the docker group
    sudo usermod -aG docker "$USER_NAME"
}

install_git() {

    echo "Installing Git..."

    # Install Git
    sudo apt-get install -y git
}

# It's recommended to install Git before installing Git LFS (Large File Storage). 
# Git LFS is an extension to Git, so it requires Git to be installed and available 
# on your system in order to function properly.
install_git_LFS() {

    echo "Installing Git LFS..."
    
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get update
    sudo apt-get install git-lfs
}

create_project_folder() {

    echo "Creating project directory..."

    sudo mkdir -p "/var/www/$REPO_NAME_ON_GITHUB"

    sudo chown -R "$USER_NAME":"$USER_NAME" "/var/www/"

    # Enters into project directory
    cd "/var/www/$REPO_NAME_ON_GITHUB" || exit 1
}

add_aliases() {
    
    # Define the path to the .bash_aliases file
    bash_aliases_file="$HOME/.bash_aliases"

    # Check if .bash_aliases already exists
    if [ ! -f "$bash_aliases_file" ]; then
        # Create .bash_aliases if it doesn't exist
        touch "$bash_aliases_file"
    fi

    echo "Creating some docker aliases ..."

    # docker ps
    alias_line="alias dockerps=\"docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}'\""
    echo "$alias_line" >> "$bash_aliases_file"
    echo "Alias 'dockerps' has been created to format better docker ps"

    # remove containers
    alias_line="alias rmcontainers=\"docker rm -f $(docker ps -a -q)\""
    echo "$alias_line" >> "$bash_aliases_file"
    echo "Alias 'rmcontainers' has been created to remove all containers"

    # remove images
    alias_line="alias rmimages=\"docker rmi -f $(docker images -a -q)\""
    echo "$alias_line" >> "$bash_aliases_file"
    echo "Alias 'rmimages' has been created to remove all images"

    # remove volumes
    alias_line="alias rmvolumes=\"docker volume rm $(docker volume ls -q)\""
    echo "$alias_line" >> "$bash_aliases_file"
    echo "Alias 'rmvolumes' has been created to remove all volumes"

    # system prune
    alias_line="alias pruneall=\"docker system prune -a\""
    echo "$alias_line" >> "$bash_aliases_file"
    echo "Alias 'pruneall' has been created"s

    # shellcheck disable=SC1090
    source "$bash_aliases_file"
}

# Tasks done with non root user

if check_variables -eq "0"; then
    create_ssh_keys
    add_know_hosts
    update_system
    install_docker
    install_docker_compose

    add_user_to_docker_group

    install_git
    install_git_LFS
    create_project_folder
    add_aliases

    echo ""
    echo "If everything went well, the following tasks have been completed:"
    echo ""
    echo "Docker installed:"
    docker -v
    echo ""
    echo "Git Installed:"
    git -v
    echo ""
    echo "Git LFS installed:"
    git lfs version
    echo ""
    echo "SSH keys created in: ~/.ssh"
    ls -lt ~/.ssh/
    echo ""
    echo "Public key copied to: ~/.ssh/authorized_keys"
    echo ""
    echo "$HOME/.ssh/know_hosts created"
    echo ""
    echo "Created project directory: /var/www/$REPO_NAME_ON_GITHUB"
    ls "/var/www/$REPO_NAME_ON_GITHUB"
    echo ""
    echo "$HOME/.bash_aliases created"

    echo "Starting a new shell with the updated group membership"
    newgrp docker

   exit;
fi


