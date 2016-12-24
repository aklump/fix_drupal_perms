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
    return 1
  fi
  return 0
}

start_dir=${PWD}
web_root=${PWD}
if [ -d public_html ]; then
  web_root="${PWD}/public_html"
elif [ -d web ]; then
  web_root="${PWD}/web"
fi
cd $web_root
echo "`tty -s && tput setaf 3`Web root is: $web_root`tty -s && tput op`"


if [ ! -d "$web_root/sites" ]; then
  echo "`tput setaf 1`This doesn\'t appear to be a Drupal install; ABORT!`tput op`"
  exit
fi

if ! confirm "Fix file permissions on this Drupal install?"; then
  exit
fi

if [ -f install.php ] && confirm "install.php found, delete it?"; then
  rm install.php
fi

if [ -f web.config ] && confirm "web.config found, delete it?"; then
  rm web.config
fi

echo "`tput setaf 2`Adjusting web file perms`tput op`"

find . -type d -exec chmod 755 {} +
find . -type f -exec chmod 644 {} +

# make any .sh files executable by user
find . -name *.sh -exec chmod 744 {} +

# user files
for i in $(find . -name files -type d); do
  if [[ "$i" == './modules/simpletest/files' ]]; then
    continue
  fi

  path="${PWD}/${i#./}"

  if [[ "$i" == "files" ]] || [[ "$i" == 'sites/default/files' ]] || confirm "Does $path need 777 permissions?"; then
    chmod -R 777 $i
    htaccess=$path/.htaccess
    if [[ ! -f $htaccess ]]; then
      echo "`tput setaf 1`Missing $htaccess file per https://drupal.org/SA-CORE-2013-003`tput op`"
    fi
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
if [ -d ../private ]; then
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

  cd "$web_root"
fi

# Delete default.settings.php
echo "`tput setaf 2`Removing default.settings.php...`tput op`"
find . -type f -name 'default.settings.php' -exec rm -v {} +

# Text files
echo "`tput setaf 2`Removing .txt files from root...`tput op`"
declare -a remove=('CHANGELOG.txt' 'COPYRIGHT.txt' 'CONTRIBUTORS*.txt' 'INSTALL*.txt' 'LICENSE*.txt' 'MAINTAINERS*.txt' 'README*.txt' 'STATUS*.txt' 'UPGRADE.txt')
for file in "${remove[@]}"; do
  for i in $(find . -maxdepth 1 -name "$file"); do
    if [ -f "$i" ]; then
      rm -v "$i"
    fi
  done
done

# One off text files
declare -a remove_one_offs=('sites/all/themes/README.txt' 'sites/all/modules/README.txt')
for file in "${remove_one_offs[@]}"; do
  if [ -f "$file" ]; then
    rm -v "$file"
  fi
done

cd $start_dir
echo "`tput setaf 2`Finished.`tput op`"
