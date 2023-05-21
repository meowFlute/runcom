#!/bin/bash

# Colors to differentiate my notes from program execution
PURPLE='\033[1;34m'
NO_COLOR='\033[0m'
# use the following for a quick copy-paste reference
# echo -e "${PURPLE}${NO_COLOR}"

# Log file
log_file=$BASEDIR/install_log.txt

# function to append to install_log.txt
append_log()
{
    echo "$(date) $1" >> $log_file
}

# Here is a function to process the files and check for symlinks and such
process_file()
{
    old_file=$1
    new_file=$2
    
    append_log "processing old_file=$old_file new_file=$new_file"
    if [ -e $old_file ]
    then
	# ~/.old_file exists
	append_log "$old_file exists"
	if [ -h $old_file ]
	then
	    # ~/.old_file is a symlink
	    append_log "$old_file is symlink"
	    echo -e "${PURPLE}$old_file is an existing symlink, note the location of the old file:${NO_COLOR}"
	    ls -l $old_file
	    append_log "$(ls -l $old_file)"
	fi
	echo -e "${PURPLE}removing $old_file${NO_COLOR}"
	rm $old_file
	append_log "$old_file removed"
    else
	append_log "$old_file does not exist"
	echo -e "${PURPLE}$old_file never existed, no worries${NO_COLOR}"
    fi

    append_log "creating new symlink"
    echo -e "${PURPLE}creating symlink $old_file -> $new_file${NO_COLOR}"
    ln -s $new_file $old_file
    ls -l $old_file
    append_log "$(ls -l $old_file)" 
}

# This is the runcom repo path
BASEDIR=$(dirname $0)

# Log file
log_file=$BASEDIR/install_log.txt

# So these are the new files
new_bashrc=$BASEDIR/.bashrc
new_inputrc=$BASEDIR/.inputrc
new_vimrc=$BASEDIR/.vimrc

# and these are the (possible) old files
home_bashrc=$HOME/.bashrc
home_inputrc=$HOME/.inputrc
home_vimrc=$HOME/.vimrc

append_log
append_log "Starting install script"
append_log
process_file $home_bashrc $new_bashrc
echo
process_file $home_inputrc $new_inputrc
echo
process_file $home_vimrc $new_vimrc

# the vimrc file needs the dracula stuff to be installed
dracula_vim_destination=$HOME/.vim/pack/themes/start
echo
if [ -e $dracula_vim_destination/dracula/colors/dracula.vim ] && [ -e $dracula_vim_destination/dracula/autoload/dracula.vim ]
then
    append_log "dracula vim files already present"
    echo -e "${PURPLE}The dracula vim files appear to already be there -- good!${NO_COLOR}"
else
    append_log "dracula vim files not present"
    if [ -d $dracula_vim_destination/dracula ]
    then
	append_log "dracula vim files not present, but directory is -- recursively deleting $dracula_vim_destination/dracula" 
	echo -e "${PURPLE}The $dracula_vim_destination/dracula folder is there, but doesn't have the right stuff in it -- deleting and cloning repo${NO_COLOR}"
	rm -rf $dracula_vim_destination/dracula
    fi
    append_log "cloning in dracula vim repo to $dracula_vim_destination/dracula"
    echo -e "${PURPLE}cloning in dracula vim repo to $dracula_vim_destination/dracula${NO_COLOR}"
    mkdir -p $dracula_vim_destination
    git clone https://github.com/dracula/vim.git $dracula_vim_destination/dracula
fi
