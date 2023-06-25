#!/bin/bash

# Script: init_c_project.sh
# Author: Scott Christensen
# Description:	
#   I want to automate the setup of c projects according to the way that I like to work.
#   These steps include:
#	1) Setting up a src directory with <proj_name>.c, <proj_name>.h, and main.c
#	2) Creating boilerplate #ifndef->#define->#endif for the header file
#	3) Creating a boilerplate hello_<proj_name>_world() function that main.c calls
#	4) Setting up a makefile that builds all object files in a build dir and the executable at the root level with a good make clean function
#	    - this makefile will run ctags and compiledb as part of the post-build process

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

print_usage() {
    echo "Usage: ${BASEDIR}/init_c_project.sh [-p project_name] [-d dir_to_init]"
}

print_help() {
    print_usage
    echo
    echo "OPTION DESCRIPTIONS:"
    echo "	-p	project_name must include no whitespace, and is used to generate the initial fileset"
    echo "	-d	dir_to_init must be an EXISTING directory"
    echo "	-h	print this help"
}

while getopts ':p:d:' opt
do
    case "$opt" in
	p)  project_name=$OPTARG
	    ;;
	d)  dir_to_init=$OPTARG
	    ;;
	h)  print_help
	    exit 1
	    ;;
	*)  print_help 
	    exit 1
	    ;;
    esac
done

# Verify inputs the lazy way (no real error descriptions) TODO break this out into individual if statements and provide better feedback
whitespace_pattern=$'[ \t]'
if [ -z "${project_name}" ] || [ -z "${dir_to_init}" ] || [[ $project_name =~ $whitespace_pattern ]] || [ ! -d $dir_to_init ]
then
    echo "INPUT ERROR: Please verify your inputs meet the following rules"
    print_help
    exit 1
fi

# Standardize the input of dir_to_init to NOT have a trailing '/'
if [ "${dir_to_init: -1}" == '/' ]
then
    dir_to_init=${dir_to_init::-1}
fi

echo_colorized -fp "Initializing ${project_name,,} the in the ${dir_to_init} folder"

# 1) Setting up a src directory with <proj_name>.c, <proj_name>.h, and main.c
echo_colorized -fP "\tGenerating ${dir_to_init}/src"
src_dir="${dir_to_init}/src"
main_file="main.c"
proj_c="${project_name,,}.c"
proj_h="${project_name,,}.h"
mkdir -p $src_dir
if [ -f "${src_dir}/${main_file}" ]; then rm "${src_dir}/${main_file}"; fi
touch "${src_dir}/${main_file}"
if [ -f "${src_dir}/${proj_c}" ]; then rm "${src_dir}/${proj_c}"; fi
touch "${src_dir}/${proj_c}"
if [ -f "${src_dir}/${proj_h}" ]; then rm "${src_dir}/${proj_h}"; fi
touch "${src_dir}/${proj_h}"

# 2) Creating boilerplate #ifndef->#define->#endif for the header file
echo_colorized -fc "\t\tCreating ${src_dir}/${proj_h}"
header_var="_${project_name^^}"
echo "#ifndef ${header_var}" >> "${src_dir}/${proj_h}"
echo "#define ${header_var}" >> "${src_dir}/${proj_h}"
echo >> "${src_dir}/${proj_h}"
echo "void hello_${project_name,,}_world(void);" >> "${src_dir}/${proj_h}"
echo >> "${src_dir}/${proj_h}"
echo "#endif // ${header_var}" >> "${src_dir}/${proj_h}"

# 3) Creating a boilerplate hello_<proj_name>_world() function that main.c calls
# create the <project_name>.c version
echo_colorized -fc "\t\tCreating ${src_dir}/${proj_c}"
echo "#include \"${proj_h}\"" >> "${src_dir}/${proj_c}"
echo "#include <stdio.h>" >> "${src_dir}/${proj_c}"
echo >> "${src_dir}/${proj_c}"
echo "void hello_${project_name,,}_world(void)" >> "${src_dir}/${proj_c}"
echo "{" >> "${src_dir}/${proj_c}"
echo "    printf(\"hello, ${project_name} world!\n\");" >> "${src_dir}/${proj_c}"
echo "}" >> "${src_dir}/${proj_c}"

# create the main.c file
echo_colorized -fc "\t\tCreating ${src_dir}/${main_file}"
echo "#include \"${proj_h}\"" >> "${src_dir}/${main_file}"
echo >> "${src_dir}/${main_file}"
echo "int main(int argc, char * argv[])" >> "${src_dir}/${main_file}"
echo "{" >> "${src_dir}/${main_file}"
echo "    hello_${project_name,,}_world();" >> "${src_dir}/${main_file}"
echo "    return 0;" >> "${src_dir}/${main_file}"
echo "}" >> "${src_dir}/${main_file}"

# 4) Setting up a makefile that builds all object files in a build dir and the executable at the root level with a good make clean function
Makefile="${dir_to_init}/Makefile"
echo_colorized -fP "\tCreating Makefile"
if [ -f $Makefile ]
then
    rm $Makefile
fi
touch $Makefile
echo -e "# Manual Inputs" >> $Makefile
echo -e "CC=gcc" >> $Makefile
echo -e "TARGET_EXEC=${project_name,,}" >> $Makefile
echo -e "BUILD_DIR=./build" >> $Makefile
echo -e "SRC_DIR=./src" >> $Makefile
echo -e "INC_DIRS := \$(SRC_DIR)" >> $Makefile
echo -e "#LDFLAGS := -lm" >> $Makefile
echo -e "" >> $Makefile
echo -e "# Find all the files we want to compile, without folder names" >> $Makefile
echo -e "SRCS := \$(wildcard \$(SRC_DIR)/*.c)" >> $Makefile
echo -e "" >> $Makefile
echo -e "# Generate Build Folder Targets" >> $Makefile
echo -e "OBJS := \$(patsubst \$(SRC_DIR)/%.c,\$(BUILD_DIR)/%.o,\$(SRCS))" >> $Makefile
echo -e "" >> $Makefile
echo -e "# Add a prefix to INC_DIRS" >> $Makefile
echo -e "INC_FLAGS := \$(addprefix -I,\$(INC_DIRS))" >> $Makefile
echo -e "" >> $Makefile
echo -e "# Compiler flags" >> $Makefile
echo -e "CFLAGS := \$(INC_FLAGS) -Wall -Wextra" >> $Makefile
echo -e "" >> $Makefile
echo -e "# make all will also run the compiledb and ctags commands" >> $Makefile
echo -e "all: post_build" >> $Makefile
echo -e "" >> $Makefile
echo -e "# The final build step." >> $Makefile
echo -e '$(TARGET_EXEC): build_dir $(OBJS)' >> $Makefile
echo -e "\t\$(CC) \$(OBJS) -o \$@ \$(LDFLAGS)" >> $Makefile
echo -e "" >> $Makefile
echo -e "build_dir:" >> $Makefile
echo -e "\tmkdir -p \$(BUILD_DIR)" >> $Makefile
echo -e "" >> $Makefile
echo -e "# Build step for all source files" >> $Makefile
echo -e '$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c' >> $Makefile
echo -e "\t\$(CC) \$(CFLAGS) -c $< -o \$@" >> $Makefile
echo -e "" >> $Makefile
echo -e "# Post-build running of ctags and compiledb" >> $Makefile
echo -e "post_build: \$(TARGET_EXEC)" >> $Makefile
echo -e "\tcompiledb -n make" >> $Makefile
echo -e "\tctags" >> $Makefile
echo -e "" >> $Makefile
echo -e ".PHONY: clean" >> $Makefile
echo -e "clean:" >> $Makefile
echo -e "\trm -rf \$(BUILD_DIR) \$(TARGET_EXEC)" >> $Makefile

# last thing we'll need is a .ctags file, I already have one of these in my runcom folder
echo_colorized -fP "\tCopying over .ctags file from ${BASEDIR}/.ctags_c"
cp "${BASEDIR}/.ctags_c" "${dir_to_init}/.ctags"
echo_colorized -fp "DONE GENERATING FILES"

# Might as well run make once everything is ready
echo_colorized -fy -br "Running 'make'"
cd $dir_to_init
make
echo_colorized -fy -br "DONE"
echo_colorized -fp "Check out your new ${project_name} project in ${dir_to_init}!"
