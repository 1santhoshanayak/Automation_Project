#!/bin/bash
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket=upgrad-santhosha
myname=santhosha
inventory_file=/var/www/html/inventory.html
inventory_file=/var/www/html/inv.html
project_name="Automation_Project"


#update sources
apt-get update -qq > /dev/null

declare -a pkgname
pkgname=("apache2" "awscli" "txt2html")

#install required packages
package_install_check(){
  package_check=`apt-cache policy $package | grep "Installed:" | awk '{ print $2 }'`

  if [ $package_check == "(none)" ]
then
        apt-get install $package -y -qq > /dev/null
fi
}

for package in ${pkgname[*]}
do
        package_install_check $package
done

#chcek apache enabled or not
apache_check=`systemctl is-enabled apache2`

if [ $apache_check == "disabled" ]
then
        systemctl enable apache2.service
fi

#check apache running status
if ! pgrep -x "apache2" >/dev/null
then
    systemctl start apache2
fi

#create tar file on /tmp
cd /var/log/apache2 && tar -cf /tmp/$myname-httpd-logs-$timestamp.tar *.log

#upload tar file to s3 bucket on creation of tar
if [ $? == 0 ]
then
        aws s3 cp /tmp/$myname-httpd-logs-$timestamp.tar s3://$s3_bucket/$myname-httpd-logs-$timestamp.tar
fi

#Task3
#check for inventory file exist
if [ ! -f $inventory_file ]
then
        echo -e '\033[1mLog Type\t Date Created\t\t Type\t Size\033[0m' >> $inventory_file
fi


#get file size and update inventory.html file
fsize=`du -hs /tmp/$myname-httpd-logs-$timestamp.tar | awk '{ print $1 }'`

echo -e "httpd-logs \t $timestamp \t tar \t $fsize" >> $inventory_file
echo -e "httpd-logs \t $timestamp \t tar \t $fsize" >> /root/$project_name/logs.txt

#update cron job
if [ ! -f "/etc/cron.d/automation" ]
then
        echo -e "0 0 * * *\troot\t/root/$project_name/automation.sh" >> /etc/cron.d/automation
fi

#additional code for proper html format when url http://publicip/inv.html

txt2html --ah /root/$project_name/header.html --outfile /var/www/html/inv.html  /root/$project_name/logs.txt

