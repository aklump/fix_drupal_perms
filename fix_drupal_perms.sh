#!/bin/bash

#
# @file
# Fix the permissions for a Drupal installation
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

if [ ! -d public_html/sites ] && [ ! -d sites ]
then
  echo "`tput setaf 1`This doesn\'t appear to be a Drupal install; ABORT!`tput op`"
  exit
fi

if ! confirm "Fix file permissions on this Drupal install?"; then
  exit
fi

if [[ -f install.php ]] && confirm "install.php found, delete it? (y/n)"; then
  rm install.php
fi

if [ -d public_html ]
then
  start_dir=${PWD}
  cd public_html
fi

echo "`tput setaf 2`Adjusting web file perms`tput op`"

find . -type d -exec chmod 755 {} +
find . -type f -exec chmod 644 {} +

# user files
for i in $(find . -name files -type d); do
  path="${PWD}/${i#./}"
  if [[ "$i" == "files" ]] || [[ "$i" == 'sites/default/files' ]] || confirm "Does $path need 777 permissions?"; then
    chmod -R 777 $i
  fi
done

# These next two are good on prod, but cause havoc with git
#find $dir/sites -name *. -maxdepth 1 -type d -exec chmod ugo-w {} +
#find $dir/sites -name default -maxdepth 1 -type d -exec chmod ugo-w {} +

# Remove write access to certain settings files
find . -name '.htaccess' -type f -exec chmod ugo-w {} +
find . -name '.htpasswd' -type f -exec chmod ugo-w {} +
find . -name 'settings*.php' -type f -exec chmod 444 {} +

# Include the private folder if it exists
if [ -d ../private ]
then
  echo
  echo "`tput setaf 2`Adjusting ../private files`tput op`"
  cd ../private
  find . -type d -exec chmod 755 {} +
  
  # user files
  for i in $(find . -name files -type d); do
    path="${PWD}/${i#./}"
    if [[ "$i" == "files" ]] || [[ "$i" == 'sites/default/files' ]] || confirm "Does $path need 777 permissions?"; then
      chmod -R 777 $i
    fi
  done

  cd ../public_html
fi

# Text files
echo "`tput setaf 2`Removing .txt files from root:`tput op`"
declare -a remove=('CHANGELOG.txt' 'COPYRIGHT.txt' 'CONTRIBUTORS*.txt' 'INSTALL*.txt' 'LICENSE*.txt' 'MAINTAINERS*.txt' 'README*.txt' 'STATUS*.txt' 'UPGRADE.txt');
for file in "${remove[@]}"; do
  for i in $(find . -name "$file"); do
    if [ -f "$i" ]; then
      rm -v "$i"
    fi
  done
done

cd $start_dir
echo "`tput setaf 2`Finished.`tput op`"
