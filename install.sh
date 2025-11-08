#!/bin/bash

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
# so now $BASEDIR should be the directory this script is being run from no matter how it was invoked

# source the echo_colors library using $BASEDIR
# This allows us to use the echo_colorized function (see echo_colors)
lib_path="$BASEDIR/echo_colors/echo_colors"
[ -z "$_echo_colors" ] && . $lib_path

# Here is a function to process the files and check for symlinks and such
process_file()
{
    old_file=$1
    new_file=$2
    
    echo_colorized -fg "Processing $old_file as needed..."
    if [ -e $old_file ] || [ -h $old_file ]
    then
	# ~/.old_file exists as a file or a symlink
	echo_colorized -fy "$old_file exists"
	if [ -h $old_file ]
	then
	    # ~/.old_file is a symlink
	    echo_colorized -fc "$old_file is an existing symlink, note the location of the old file:"
	    ls -l $old_file

	fi
	echo_colorized -fr "removing $old_file"
	rm $old_file

    else
	echo_colorized "$old_file never existed, no worries"
    fi

    echo_colorized "creating symlink $old_file -> $new_file"
    ln -s $new_file $old_file
    ls -l $old_file

}

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

# There are a few steps that use Vundle, so we need to install that as well
echo
echo_colorized -fg "Installing Vundle from github"
if [ -e $HOME/.vim/bundle/Vundle.vim ]
then
    echo_colorized -fy "    Vundle is already installed"
else
    git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
fi

# Vundle install now that .vimrc is correct
echo_colorized -fg "\nInstalling Vundle Packages"
vim +PluginInstall +qall
echo_colorized -fg "Vundle Packages Installed"

echo

echo_colorized -fp "Just going to set some git --global configs to be vim"
git config --global core.editor vim
git config --global diff.tool vimdiff
git config --global merge.tool vimdiff
git config --global --add difftool.prompt false

echo_colorized "All done!"
echo_colorized -fy -br "INSTALL NOTE"
echo_colorized -fy "Remember, you now have the script library echo_colors"
echo_colorized -fy "Refer to runcom/echo_colors/echo_colors_test.sh"
