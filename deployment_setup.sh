# update
sudo apt update -y
sudo apt upgrade -y

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# install pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -

# alias pnpm as pn
# IMPORTANT: change with the shell rc file used here
echo "alias pn=\"pnpm\"" >> ~/.bashrc
source ~/.bashrc

nvm install --lts

