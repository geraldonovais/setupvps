#!/bin/bash

source .env

check_env_file() {

    status=0
    env_file=".env"

    # Check if .env file exists
    if [ ! -f "$env_file" ]; then
        echo "Error: .env file not found."
        status=1
    fi

    # Check if each line in .env file is well-formatted
    while IFS= read -r line; do

        # Skip blank lines and comment lines
        if [[ "$line" =~ ^\s*$ || "$line" =~ ^\s*# ]]; then
            continue
        fi

        # Extract the value part of the line
        value=$(echo "$line" | cut -d '=' -f 2-)

        # Check if there ares values inside angle brackets
        if grep -qE '[<>]' <<< "$value"; then
            printf '\e[31m%s\e[0m' "Error: .env file is not well-formatted."
            echo ""
            echo "Replace with your values without these characters < & >: $value"
            status=1
        fi

        if [[ ! "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
            echo "Error: .env file is not well-formatted. Invalid line: $line"
            status=1
        fi

    done < "$env_file"

    return $status
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
install_git_fls() {

    echo "Installing Git FLS..."
    
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get update
    sudo apt-get install git-lfs
}

init_git_repo() {

    echo "Creating project directory..."

    sudo mkdir -p "/var/www/$REPO_NAME_ON_GITHUB"

    sudo chown -R "$USER_NAME":"$USER_NAME" "/var/www/"

    # Enters into project directory
    cd "/var/www/$REPO_NAME_ON_GITHUB" || exit 1

    git config --global init.defaultBranch main --verbose

    # initialize a git repo
    git init

    # Configure Git
    git remote add origin "$REPO_SSH_URL"
}

setup_git_FLS() {
   
    # Enters into project directory
    cd "/var/www/$REPO_NAME_ON_GITHUB" || exit 1

    git lfs install

    # Git FLS will track jpg, png, gif, svg, psd, and sql files
    git lfs track "*.jpg" "*.png" "*.gif" "*.svg" "*.psd" "*.sql"
}

install_deploy_key_on_github () {

    echo "Installing deploy key on GitHub..."

    # Read the public key file into a variable
    PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)

    # Create the deploy key using the GitHub API
    curl -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$REPO_OWNER/$REPO_NAME_ON_GITHUB/keys \
    -d '{"title": "Deploy Key", "key": "'"$PUBLIC_KEY"'", "read_only": true}'
}

# Tasks done with non root user


if check_env_file -eq "0"; then
    create_ssh_keys
    update_system
    install_docker
    add_user_to_docker_group

    install_git
    install_git_fls
    init_git_repo
    setup_git_FLS

    #install_deploy_key_on_github
   exit;
fi


