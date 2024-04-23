# setupvps
Script to install Docker, Git, Git LFS on your VPS and configure the first deploy from your GitHub account  

## Requirements

A cloud server, virtual private server (VPS) or dedicated server, with an install of:

- Ubuntu 22.04 or later

## Create a user

First type these two commands replacing `<user>` and `<password>` with the user name you want to create

```bash
export USER_NAME=<user_name>
export USER_PASSWORD=<user_password>
````

Now, copy and paste the lines below to execute the commands in sequence. It will create the user, add it to sudo group, set the shell type and swith to the new user.

```bash
useradd -m $USER_NAME
echo "$USER_NAME:$USER_PASSWORD" | sudo chpasswd
usermod -aG sudo $USER_NAME
chsh -s /bin/bash $USER_NAME
su - $USER_NAME
````

To make sure the user was created, just type `ls /home/` and you will see the name of the new user

## Download the script along with environment variables file to complete the task:

```bash
curl -fLo setupvps.sh https://raw.githubusercontent.com/geraldonovais/setupvps/main/setupvps.sh
curl -fLo .env https://raw.githubusercontent.com/geraldonovais/setupvps/main/.env
````
Give permissions to execute

```bash
chmod 700 setupvps.sh
````
### Update the .env file 

Update the .env file you just downloaded with your values. For example, in my case it was:

```bash
# REPO_NAME_ON_GITHUB
# This variable will be used to:
# create the project folder with the same name in /var/www/
# Init a empty Git repo in your project folder
# Setup git FLS in your project folder
REPO_NAME_ON_GITHUB=<repository>

# USER_NAME
# Must be the same user you have created when you did "export USER_NAME=<user_name>"
# This variable will be used to:
# Create your ssh keys and put in your home directory
# Add your user name to docker group
# Add your user as owner of the "/var/www/" folder
USER_NAME=<user>
````