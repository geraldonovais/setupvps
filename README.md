# setupvps
Script to install Docker, Git, Git LFS, generate SSH keys and create your project folder in your virtual private server (VPS)

## Requirements

A cloud server, virtual private server (VPS) or dedicated server, with an install of:

- Ubuntu 22.04 or later

## Create a user

Copy and paste this command replacing `<user>` and `<password>` with the user name you want to create

```bash
export USER_NAME="<user_name>" && export USER_PASSWORD="<user_password>"
````

Now, copy and paste the entire block of code below. The commands will be executed in sequence. It will create the user, add it to sudo group, set the shell type and swith to the new user. You don't need to replace the variables as the values come from the export made previously

```bash
useradd -m $USER_NAME
echo "$USER_NAME:$USER_PASSWORD" | sudo chpasswd
usermod -aG sudo $USER_NAME
chsh -s /bin/bash $USER_NAME
su - $USER_NAME
````

To make sure the user was created, just type `ls /home/` and you will see the name of the new user

## Download the .env file (environment variables):

```bash
curl -fLo .env https://raw.githubusercontent.com/geraldonovais/setupvps/main/.env 
````
Change permissions

```bash
chmod 600 .env
````

### Update the .env file 

Update the .env file with values that suit for you

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

## Download the shell script to complete the task:

```bash
curl -fLo setupvps.sh https://raw.githubusercontent.com/geraldonovais/setupvps/main/setupvps.sh
````
Give permissions to execute

```bash
chmod 700 setupvps.sh
````

## Run the script

Now that you've updated the .env file with your own values, you can run the script:

```bash
./setupvps.sh
````

After execution, the script displays a report with everything that was done. 

Enjoy it, because you don't need to do things manually :)