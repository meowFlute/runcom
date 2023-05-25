#!/bin/bash

# Colors to differentiate my notes from program execution
PURPLE='\033[1;34m'
NO_COLOR='\033[0m'
# use the following for a quick copy-paste reference
# echo -e "${PURPLE}${NO_COLOR}"

# Let's locate the absolute path of this script first
# I got this from https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script/246128#246128
SOURCE=${BASH_SOURCE[0]}
pushd . > /dev/null # stores off where we were before all that cd'ing, might not be necessary
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
BASEDIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
popd > /dev/null # This just gets us back to where we were before all that cd'ing

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
    if [ -e $old_file ] || [ -f $old_file ]
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

# Let's see if we can identify the terminal emulator being used and verify/change its theme to dracula as well
terminal_emulator=
if [ "$TERM" != "linux" ] # make sure we aren't in a tty session
then
    current_pid=$BASHPID
    parent_pid=$PPID
    # First we need to indentify the terminal emulator binary
    while [ ! `ps -o cmd= --pid ${parent_pid} | sed 's/ .*$//g' | grep terminal` ] && [ ! ${parent_pid} = "1" ]
    do
	# pass off last round of loop
	current_pid=$parent_pid
	append_log "current_pid=$(echo $current_pid)"
	# echo $current_pid
	# This command gets the parent pid (ppid) of the current pid
	parent_pid=`ps -o ppid= --pid $current_pid`
	append_log "parent_pid=$(echo $parent_pid)"
	# echo $parent_pid
	# This one gets the array of the command + args used to call the terminal
	parent_cmd_arr=( `ps -o cmd= --pid $parent_pid` )
	append_log "parent_cmd_arr=( ${parent_cmd_arr[@]} )"
	# echo ${parent_cmd_arr[@]}
	# Index zero is the binary
	parent_cmd=${parent_cmd_arr[0]}
	append_log "parent_cmd=$parent_cmd"
	# echo ${parent_cmd}
    done
fi
# Let's see what we ended up with
if [ `echo $parent_cmd | grep terminal` ]
then
    case "$parent_cmd" in
	*xfce4-terminal)    terminal_emulator=xfce4	 ;;
	*gnome-terminal)    terminal_emulator=gnome	 ;;
	*)  echo "unknown terminal emulator $parent_cmd" ;;
    esac
else
    echo "looks like the ppid tree never has one with terminal in it! No bueno! We won't bother with the color scheme then"
fi
append_log "terminal_emulator=$terminal_emulator"
if [ ${#terminal_emulator} > 0 ]
then
    echo "$parent_cmd looks like the ${terminal_emulator}-terminal"
    if [ "$terminal_emulator" = "xfce4" ]
    then
	echo "installing dracula theme for xfce4-terminal"
	# here we try and see if we've done the right stuff to get the dracula theme
	# download the dracula.theme from git if it isn't already present where I want it
	# check to see if the theme is correct and fix it if it isn't
	# (might make sense just to save a version of my ~/.config/xfce4/terminal/terminalrc and cp over the top of it based on a `diff`)
    elif [ "$terminal_emulator" = "gnome" ]
    then
	echo "installing dracula theme for gnome-terminal"
	# check for dconf-cli using dpkg or something
	# sudo apt-get install dconf-cli
	# git clone https://github.com/dracula/gnome-terminal to_somewhere
	# `/bin/bash /gnome-terminal_location_I_just_cloned/install.sh`
    fi
fi
