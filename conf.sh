#!/bin/bash
echo "Configuring Git..."
git config --global user.name "grzegorz brzęczyszczykiewicz"
git config --global user.email "starsmall890@gmail.com"
# Generate SSH key
echo "Generating SSH key..."
yes | ssh-keygen -t ed25519


# Add SSH private key to ssh-agent
ssh-add ~/.ssh/id_ed25519

# Print SSH
cat ~/.ssh/id_ed25519.pub

# Open GitHub SSH key settings in Firefox
firefox https://github.com/settings/ssh/new
firefox https://platform.alem.school/git/user/settings/keys
echo "Script completed! You can now add your SSH key to GitHub."
