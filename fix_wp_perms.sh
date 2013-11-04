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

if [ ! -d public_html/wp-content ] && [ ! -d wp-content ]
then
  echo "This doesn't appear to be a WordPress install; ABORT!"
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
