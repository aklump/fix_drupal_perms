#Summary
This is a collection of BASH scripts to modify the file permissions for popular web apps including Drupal and Wordpress.

#Installation
1. Install `fix_drupal_perms.sh` in a directory in your `$PATH` variable and make it executable, probably via a symlink fix_drupal_perms. e.g., 

        cd ~/bin
        git clone https://github.com/aklump/fix_drupal_perms.git fix_drupal_perms_files
        ln -s fix_drupal_perms_files/fix_drupal_perms.sh fix_drupal_perms
        ln -s fix_drupal_perms_files/fix_wp_perms.sh fix_wp_perms

#Usage
## For Drupal
1. Navigate to the doc root of a drupal installation in shell and execute `fix_drupal_perms`.

## For Wordpress
1. Navigate to the doc root of a wordpress installation in shell and execute `fix_wp_perms`.

##Contact
* **In the Loft Studios**
* Aaron Klump - Developer
* PO Box 29294 Bellingham, WA 98228-1294
* _aim_: theloft101
* _skype_: intheloftstudios
* _d.o_: aklump
* <http://www.InTheLoftStudios.com>