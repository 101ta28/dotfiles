# git-complettion settings
if [ -e $HOME/.git-completion.bash ]
then
	source $HOME/.git-completion.bash
fi

if [ -e $HOME/.git-prompt.sh ]
then
	GIT_PS1_SHOWDIRTYSTATE=true
	GIT_PS1_SHOWUNTRACKEDFILES=true
	GIT_PS1_SHOWSTASHSTATE=true
	GIT_PS1_SHOWUPSTREAM=auto
fi
