#Installing Python 3 on a Mac using Homebrew
#
# IMPORTANT NOTE!
# These commands are NOT my work! Check out
# https://opensource.com/article/19/5/python-3-default-mac
# for more information on this workflow!
#
# This file should only be considered as the cliffnotes of 
# Matthew Broberg and Moshe Zadka's work!

#Get Homebrew: 
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#Update Homebrew: 
brew update

#Install Pyenv: 
brew install pyenv

#Get available Python versions to install: 
pyenv install --list
#Grab the latest version towards the top of the output...above the anaconda and activepython listings

#Install Python with Pyenv: 
pyenv install 3.9.2

#Set our installed Python version as our global default:
pyenv global 3.9.2

#Verify it is set
pyenv version

#Throw this statement into your bash or zsh profile:
if command -v pyenv 1>/dev/null 2>&1; then
	eval "$(pyenv init -)"
fi

#Reload your bash or zsh profile

#Check to see that macOS is now using Python 3
python --version

#Install requests via pip
pip install requests