#!/bin/bash

echo "Configuring Git..."
git config --global user.name "grzegorz brzęczyszczykiewicz"
git config --global user.email "starsmall890@gmail.com"

# Generate SSH key with default path and empty passphrase
echo "Generating SSH key..."
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""

# Start ssh-agent if not already running
eval "$(ssh-agent -s)"

# Add SSH private key to ssh-agent
ssh-add ~/.ssh/id_ed25519

# Print SSH public key
echo -e "\nYour SSH public key:"
cat ~/.ssh/id_ed25519.pub

# Open GitHub SSH key settings in Firefox
firefox https://github.com/settings/ssh/new &
firefox https://platform.alem.school/git/user/settings/keys &

echo "Script completed! You can now add your SSH key to GitHub."
