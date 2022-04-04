#!/bin/sh

DFILE_PATH="$HOME/.dfiles"

ln -sf "$DFILE_PATH"/.bash_aliases ~/.bash_aliases
ln -sf "$DFILE_PATH"/.bash_logout ~/.bash_logout
ln -sf "$DFILE_PATH"/.bashrc ~/.bashrc
ln -sf "$DFILE_PATH"/.git-completion.bash ~/.git-completion.bash
ln -sf "$DFILE_PATH"/.git-prompt.sh ~/.git-prompt.sh
ln -sf "$DFILE_PATH"/.gitconfig ~/.gitconfig
ln -sf "$DFILE_PATH"/.profile ~/.profile
ln -sf "$DFILE_PATH"/.yarnrc ~/.yarnrc

# vim settings
mkdir -p ~/.vim/undo
ln -sf $DFILE_PATH/.vimrc ~/.vimrc
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
sh ./installer.sh ~/.cache/dein
rm installer.sh
echo "Use Vim and input command"
echo ":call dein#install()"

# git-credential-manager settings
curl -LO https://raw.githubusercontent.com/GitCredentialManager/git-credential-manager/main/src/linux/Packaging.Linux/install-from-source.sh &&
sh ./install-from-source.sh &&
git-credential-manager-core configure

. ~/.bashrc
