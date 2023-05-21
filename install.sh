#!/bin/bash

# Colors to differentiate my notes from program execution
PURPLE='\033[1;34m'
NO_COLOR='\033[0m'
# use the following for a quick copy-paste reference
# echo -e "${PURPLE}${NO_COLOR}"

# Here is a function to process the files and check for symlinks and such
process_file()
{
    old_file=$1
    new_file=$2

    if [ -e $old_file ]
    then
	# ~/.old_file exists
	if [ -h $old_file ]
	then
	    # ~/.old_file is a symlink
	    echo -e "${PURPLE}$old_file is an existing symlink, note the location of the old file:${NO_COLOR}"
	    ls -l $old_file
	fi
	echo -e "${PURPLE}removing $old_file${NO_COLOR}"
	rm $old_file
    else
	echo -e "${PURPLE}$old_file never existed, no worries${NO_COLOR}"
    fi

    echo -e "${PURPLE}creating symlink $old_file -> $new_file${NO_COLOR}"
    ln -s $new_file $old_file
}

# This is the runcom repo path
BASEDIR=$(dirname $0)

# So these are the new files
new_bashrc=$BASEDIR/.bashrc
new_inputrc=$BASEDIR/.inputrc
new_vimrc=$BASEDIR/.vimrc

# and these are the (possible) old files
home_bashrc=$HOME/.bashrc
home_inputrc=$HOME/.inputrc
home_vimrc=$HOME/.vimrc

process_file $home_bashrc $new_bashrc
echo
process_file $home_inputrc $new_inputrc
echo
process_file $home_vimrc $new_vimrc

# the vimrc file needs the dracula stuff to be installed
dracula_vim_destination=$HOME/.vim/pack/themes/start
echo
echo -e "${PURPLE}cloning in dracula vim repo to $dracula_vim_destination/dracula${NO_COLOR}"
mkdir -p $dracula_vim_destination
git clone https://github.com/dracula/vim.git $dracula_vim_destination/dracula