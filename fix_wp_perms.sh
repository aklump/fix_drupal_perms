#!/bin/bash

#
# @file
# Fix the permissions for a WordPress installation
#

##
 # Accept a y/n confirmation message or end
 #
function confirm() {
  echo "$1 (y/n)"
  read -n 1 a
  echo
  if [ "$a" != 'y' ]
  then
    echo 'CANCELLED!'
    return
  fi
}

if [ ! -e public_html/wp-config.php ] && [ ! -e wp-config.php ]
then
  echo "This doesn't appear to be a WordPress install (wp-config.php not found); ABORT!"
  exit
fi

confirm 'Fix file permissions on this WordPress install?'

if [ -d public_html ]
then
  start_dir=${PWD}
  cd public_html
fi

echo 'Adjusting web file perms'

find . -type d -exec chmod -v 755 {} +
find . -type f -exec chmod -v 644 {} +
find . -name wp-content -type d -exec chmod -v 777 {} +

# Make sure that define('FS_METHOD', 'direct'); appears in wp-config.php
found=$(grep -c "FS_METHOD" wp-config.php)
if [[ $found -eq 0 ]]; then
  find . -name 'wp-config*.php' -type f -exec chmod -v 744 {} +  
  echo "Added define('FS_METHOD', 'direct'); to wp-config.php"
  echo >> wp-config.php
  echo "define('FS_METHOD', 'direct');" >> wp-config.php
fi

# Remove write access to certain settings files
find . -name '.htaccess' -type f -maxdepth 1 -exec chmod -v ugo-w {} +
find . -name '.htpasswd' -type f -exec chmod -v ugo-w {} +
find . -name 'wp-config*.php' -type f -exec chmod -v 444 {} +

echo 'Removing .txt files from root:'
declare -a remove=('license.txt' 'readme.html');
for file in "${remove[@]}"
do
  if [ -f "$file" ]
  then
    rm -v $file
  fi
done

cd $start_dir
echo 'Finished'
