# update
sudo apt update -y
sudo apt upgrade -y

# install ohmyzsh
sudo apt install zsh fzf git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install zsh packages
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone https://github.com/changyuheng/zsh-interactive-cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-interactive-cd
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

# enable all plugins
nano ~/.zshrc

# add the following lines in the plugins array
$ plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions fast-syntax-highlighting zsh-interactive-cd fzf-tab)

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

sudo apt install nginx -y

# Docker installation
# taken from:  https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-22-04
# Add Docker's official GPG key: 
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
sudo apt-get install postgresql-client-common

# fix permissions
sudo usermod -aG docker $USER

# then reboot

# run postgres (optional)
docker run -d -p 2345:5432 -e POSTGRES_PASSWORD=getarctype postgres

# install pm2
pn install -g pm2
