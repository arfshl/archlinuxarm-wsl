#!/bin/bash

set -ue

DEFAULT_GROUPS='adm,cdrom,sudo,dip,plugdev'
DEFAULT_UID='1000'

echo 'Please create a default UNIX user account. The username does not need to match your Windows username.'
echo 'For more information visit: https://aka.ms/wslusers'

if getent passwd "$DEFAULT_UID" > /dev/null ; then
  echo 'User account already exists, skipping creation'
  exit 0
fi

while true; do

  # Prompt from the username
  read -p 'Enter new UNIX username: ' username

  # Create the user
  # Prompt from the username
  read -p 'Enter new UNIX username: ' username

  if /usr/sbin/useradd -m -u "$DEFAULT_UID" -G "$DEFAULT_GROUPS" -s /bin/bash "$username"; then
    if passwd "$username"; then
      break
    else
      /usr/sbin/userdel -r "$username"
    fi
  fi
done
