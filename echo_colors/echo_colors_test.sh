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
lib_path="$BASEDIR/echo_colors"
[ -z "$_echo_colors" ] && . $lib_path

# run the test
test_colors

# test functionality of echo_colorized
echo_colorized "this should be purple because I passed no arguments"
echo_colorized -f r "this should be red"
echo_colorized -fc "does this work? (cyan with different opt arg syntax than red)" # ya that syntax appears to work fine
echo_colorized -fy -br "PANIC!!! combo attempt"
echo_colorized -bP "background change only"
echo_colorized -x "what does an incorrect argument do?"
echo_colorized "does it allow us to keep going in our original script?" # yes indeed, it does!
