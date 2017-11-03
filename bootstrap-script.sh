#!/bin/bash

read -p "What site would you like to work with? (ie. jse-soe) " sync_site
echo "drupal_domain $sync_site" >> local_vars.yml

echo "Let's make sure we have Docker and Ansible installed."
echo "As well as, Docker related python packages."
if [ ! -f /usr/local/bin/pip ]; then sudo easy_install pip; fi

ansible_package=$(pip list --format=legacy | grep "ansible")
dockerpy_package=$(pip list --format=legacy | grep "docker-py")
if [ -z "$ansible_package" ]; then sudo pip install ansible==2.3.1.0; fi
if [ -z "$dockerpy_package" ]; then sudo pip install docker-py==1.10.6; fi

if [ ! -x /usr/local/bin/docker ] && [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Installing Docker via wget"
  wget https://download.docker.com/mac/stable/Docker.dmg $HOME/.
  echo "Find Docker.dmg in your $HOME directory and click to install."
  read -p "Have you started the Docker Application? " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    continue
  else
    echo "I'm afraid you can't continue until Docker is running on your machine."
    exit
  fi
else
  echo "Docker is already installed."
fi

echo "Add IP alias, so we can connect to the container."
sudo ifconfig lo0 alias 192.168.88.88/24

# Always output Ansible log in color
export ANSIBLE_FORCE_COLOR=true

# Export commands for working with container
alias le-restart='sudo ifconfig lo0 alias 192.168.88.88/24 && docker start drupalvm && docker exec -it drupalvm /var/www/'
alias le-setup='ansible-playbook -c docker -i inventory setup-playbook.yml -K'
alias le-refresh='ansible-playbook -c docker -i inventory refresh-playbook.yml'
