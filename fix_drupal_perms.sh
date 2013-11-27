#!/bin/bash

#
# @file
# Fix the permissions for a Drupal installation
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

if [ ! -d public_html/sites ] && [ ! -d sites ]
then
  echo "This doesn't appear to be a Drupal install; ABORT!"
  exit
fi

confirm 'Fix file permissions on this Drupal install?'

if [[ -f install.php ]]; then
  echo "`tput setaf 3`install.php found, delete it? (y/n)`tput op`"
  read -n 1 a
  if [ "$a" == 'y' ]
  then
    rm install.php
  fi
fi

if [ -d public_html ]
then
  start_dir=${PWD}
  cd public_html
fi

echo 'Adjusting web file perms'

find . -type d -exec chmod -v 755 {} +
find . -type f -exec chmod -v 644 {} +
find . -name files -type d -exec chmod -v 777 {} +

# These next two are good on prod, but cause havoc with git
#find $dir/sites -name *. -maxdepth 1 -type d -exec chmod -v ugo-w {} +
#find $dir/sites -name default -maxdepth 1 -type d -exec chmod -v ugo-w {} +

# Remove write access to certain settings files
find . -name '.htaccess' -type f -maxdepth 1 -exec chmod -v ugo-w {} +
find . -name '.htpasswd' -type f -exec chmod -v ugo-w {} +
find . -name 'settings*.php' -type f -exec chmod -v 444 {} +

# Include the private folder if it exists
if [ -d ../private ]
then
  echo
  echo 'Adjusting ../private files'
  cd ../private
  find . -type d -exec chmod -v 755 {} +
  find . -name files -type d -exec chmod -v 777 {} +
  cd ../public_html
fi

echo 'Removing .txt files from root:'
declare -a remove=('CHANGELOG.txt' 'COPYRIGHT.txt' 'CONTRIBUTORS*.txt' 'INSTALL*.txt' 'LICENSE*.txt' 'MAINTAINERS*.txt' 'README*.txt' 'STATUS*.txt' 'UPGRADE.txt');
for file in "${remove[@]}"
do
  rm -v $file
done

cd $start_dir
echo 'Finished'
