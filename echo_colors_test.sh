#!/bin/bash

# source the echo_colors library
lib_path="$(dirname $0)/../lib/echo_colors"
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
