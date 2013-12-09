#!/bin/bash

#
# @file
# Fix the permissions for a WordPress installation
#

##
 # Accept a y/n confirmation message or end
 #
function confirm() {
  echo "`tput setaf 3`$1 (y/n)`tput op`"
  read -n 1 a
  echo
  if [ "$a" != 'y' ]; then
    return -1
  fi
  return 0
}

if [ ! -e public_html/wp-config.php ] && [ ! -e wp-config.php ]
then
  echo "This doesn't appear to be a WordPress install (wp-config.php not found); ABORT!"
  exit
fi

if ! confirm 'Fix file permissions on this WordPress install?'; then
  exit
fi

if [ -d public_html ]
then
  start_dir=${PWD}
  cd public_html
fi

echo 'Adjusting web file perms'

find . -type d -exec chmod 755 {} +
find . -type f -exec chmod 644 {} +

#http://codex.wordpress.org/Hardening_WordPress
chmod 777 .htaccess
chmod 777 wp-content
chmod -R 777 wp-content/themes
chmod -R 777 wp-content/uploads

# Make sure that define('FS_METHOD', 'direct'); appears in wp-config.php
found=$(grep -c "FS_METHOD" wp-config.php)
if [[ $found -eq 0 ]]; then
  find . -name 'wp-config*.php' -type f -exec chmod 744 {} +  
  echo "Added define('FS_METHOD', 'direct'); to wp-config.php"
  echo >> wp-config.php
  echo "define('FS_METHOD', 'direct');" >> wp-config.php
fi

# Remove write access to certain settings files
find . -name '.htpasswd' -type f -exec chmod ugo-w {} +
find . -name 'wp-config*.php' -type f -exec chmod 444 {} +

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
echo "`tput setaf 2`Finished.`tput op`"
