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

## Download the shell script to complete the task:

```bash
curl -fLo setupvps.sh https://raw.githubusercontent.com/geraldonovais/setupvps/main/setupvps.sh && chmod 700 setupvps.sh
````

### Update the variables at the beginning of the script with the values that suit for you

`REPO_NAME_ON_GITHUB`  and `USER_NAME`

### Run the script

Now, if you have updated the variables at the beginning of the script with your own values, you can run `setupvps.sh`:

```bash
./setupvps.sh
````

After execution, the script displays a report with everything that was done. 

Enjoy it, because you don't need to do things manually :)