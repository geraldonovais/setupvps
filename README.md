# setupvps
Script to install Docker, Git, Git LFS on your VPS and configure the first deploy from your GitHub account  

## Create a user

First type these two commands replacing `<user>` and `<password>` with the user name you want to create

```bash
export USER_NAME=<user_name>
export USER_PASSWORD=<user_password>
````

Now, copy and paste the lines below to execute the commands in sequence. It will create the user, add it to sudo group, set the shell type and swith to the new user.

```bash
useradd -m $USER_NAME
echo "$USER_NAME: $USER_PASSWORD " | sudo chpasswd
usermod -aG sudo $USER_NAME
chsh -s /bin/bash $USER_NAME
su - $USER_NAME
````

To make sure the user was created, just type `ls /home/` and you will see the name of the new user

## Download the script to accomplish the task:

```bash
curl -O https://github.com/geraldonovais/setupvps/blob/main/.env
curl -O https://github.com/geraldonovais/setupvps/blob/main/setupvps.sh
````
Give permissions to execute

```bash
chmod 700 setupvps.sh
````