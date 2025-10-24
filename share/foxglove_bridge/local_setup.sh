#!/bin/bash
# generated from ament_package/template/package_level/local_setup.sh.in

# since this file is sourced use either the provided AMENT_CURRENT_PREFIX
# or fall back to the destination set at configure time
: ${AMENT_CURRENT_PREFIX:="/opt/ros/humble"}
if [ ! -d "$AMENT_CURRENT_PREFIX" ]; then
  if [ -z "$COLCON_CURRENT_PREFIX" ]; then
    echo "The compile time prefix path '$AMENT_CURRENT_PREFIX' doesn't " \
      "exist. Consider sourcing a different extension than '.sh'." 1>&2
  else
    AMENT_CURRENT_PREFIX="$COLCON_CURRENT_PREFIX"
  fi
fi

# function to append values to environment variables
# using colons as separators and avoiding leading separators
ament_append_value() {
  # arguments
  _listname="$1"
  _value="$2"

  # avoid leading separator
  eval _values=\"\$$_listname\"
  if [ -z "$_values" ]; then
    eval export $_listname=\"$_value\"
  else
    eval export $_listname=\"$_values:$_value\"
  fi
}

# function to prepend a value to an environment variable
# using colons as separators and avoiding trailing separators
ament_prepend_value() {
  # arguments
  _listname="$1"
  _value="$2"

  # avoid trailing separator
  eval _values=\"\$$_listname\"
  if [ -z "$_values" ]; then
    eval export $_listname=\"$_value\"
  else
    eval export $_listname=\"$_value:$_values\"
  fi
}

# source environment hooks
AMENT_ENVIRONMENT_HOOKS=""
AMENT_RETURN_ENVIRONMENT_HOOKS=""

# source environment hooks for this package
if [ -n "$AMENT_ENVIRONMENT_HOOKS" ]; then
  for _hook in $AMENT_ENVIRONMENT_HOOKS; do
    if [ -f "$_hook" ]; then
      . "$_hook"
    fi
  done
fi

# set environment variables
ament_append_value AMENT_PREFIX_PATH "/opt/ros/humble"
ament_append_value LD_LIBRARY_PATH "/opt/ros/humble/lib"
ament_append_value PATH "/opt/ros/humble/bin"
ament_append_value PYTHONPATH "/opt/ros/humble/lib/python3.10/site-packages"

# return environment hooks
if [ -n "$AMENT_RETURN_ENVIRONMENT_HOOKS" ]; then
  for _hook in $AMENT_RETURN_ENVIRONMENT_HOOKS; do
    if [ -f "$_hook" ]; then
      . "$_hook"
    fi
  done
fi
