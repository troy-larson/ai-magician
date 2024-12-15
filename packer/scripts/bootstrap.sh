#!/bin/bash

# Set DEBIAN_FRONTEND to noninteractive to avoid any prompts
export DEBIAN_FRONTEND=noninteractive

echo "Waiting 60 seconds for droplet to finish boostrapping..."
sleep 60

# Function to wait for the lock to be released
wait_for_unlock() {
  while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Waiting for lock to be released..."
    sleep 5
  done

  # Identify the process holding the lock
  lock_holder=$(sudo fuser /var/lib/dpkg/lock-frontend 2>/dev/null)
  if [ -n "$lock_holder" ]; then
    echo "Lock is held by process ID: $lock_holder"
    ps -p $lock_holder -o pid,cmd --no-headers
  fi
}

# Wait for the initial lock to be released
wait_for_unlock
sudo add-apt-repository universe
sudo apt-get update -y
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common \
  zsh \
  git \
  vim \
  mc

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

sudo apt-get update
sudo apt-get install -y docker-ce git zsh mc vim

# Change default shell to Zsh
sudo chsh -s $(which zsh) $(whoami)

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone Oh My Zsh and plugins
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git -C ~/.oh-my-zsh/custom/plugins clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git
git -C ~/.oh-my-zsh/custom/plugins clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git
git -C ~/.oh-my-zsh/custom/themes clone --depth=1 https://github.com/romkatv/powerlevel10k.git

# Configure Zsh
cat >~/.zshrc <<\END
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH=~/.oh-my-zsh
DISABLE_AUTO_UPDATE=true
DISABLE_MAGIC_FUNCTIONS=true
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(zsh-syntax-highlighting zsh-autosuggestions)

source ~/.oh-my-zsh/oh-my-zsh.sh
source ~/.p10k.zsh
END

cat >~/.p10k.zsh <<\END
# put the content of your own .p10k.zsh here
END
